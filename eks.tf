# Module docs: https://registry.terraform.io/modules/terraform-aws-modules/eks/aws

# Get current account_id
data "aws_caller_identity" "current" {}

data "aws_eks_cluster_auth" "eks_cluster" {
  name = var.eks_cluster_name
}

data "aws_iam_role" "terraform_cloud_admin" {
  name = "terraform_cloud_admin"
}

data "aws_iam_role" "aws_sso_admin" {
  name = var.aws_sso_admin_role_name
}

output "tf_role" {
  value = data.aws_iam_role.terraform_cloud_admin
}
output "sso_role" {
  value = data.aws_iam_role.aws_sso_admin
}


module "eks_cluster" {
  source          = "terraform-aws-modules/eks/aws"
  version         = "~> 19.0"
  cluster_name    = var.eks_cluster_name
  cluster_version = "1.25"
  subnet_ids      = module.vpc.private_subnets
  vpc_id          = module.vpc.vpc_id

  cluster_endpoint_public_access = true

  cluster_addons = {
    coredns = {
      preserve    = true
      most_recent = true

      timeouts = {
        create = "25m"
        delete = "10m"
      }
    }
    kube-proxy = {
      most_recent = true
    }
    vpc-cni = {
      most_recent = true
    }
  }

  eks_managed_node_groups = {
    nodes = {
      min_size     = 1
      max_size     = 3
      desired_size = 2

      instance_types = ["t3.xlarge"]
      capacity_type  = "SPOT"
    }
  }

  cluster_security_group_additional_rules = {
    # open up access to higher ports from control plane
    egress_nodes_ephemeral_ports_tcp = {
      description                = "To node 1025-65535"
      protocol                   = "tcp"
      from_port                  = 1025
      to_port                    = 65535
      type                       = "egress"
      source_node_security_group = true
    }
  }

  node_security_group_additional_rules = {
    # open up traffic from control plane
    control_plane_all = {
      description = "Control plane all ports/protocols"
      protocol    = "-1"
      from_port   = 0
      to_port     = 0
      type        = "ingress"
      source_cluster_security_group = true
    }
    # open up node-to-node traffic
    ingress_self_all = {
      description = "Node to node all ports/protocols"
      protocol    = "-1"
      from_port   = 0
      to_port     = 0
      type        = "ingress"
      self        = true
    }
    # allow wide internet access
    egress_all = {
      description      = "Node all egress"
      protocol         = "-1"
      from_port        = 0
      to_port          = 0
      type             = "egress"
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = ["::/0"]
    }
  }

  # aws-auth configmap
  # If issue encountered see: https://github.com/hashicorp/terraform-provider-kubernetes/issues/1720#issuecomment-1453738911
  create_aws_auth_configmap = true
  manage_aws_auth_configmap = true

  aws_auth_roles = [
    # Add SSO Role(s) and Role for Terraform Cloud
    {
      rolearn  = data.aws_iam_role.aws_sso_admin.arn
      username = "awsadmin"
      groups   = ["system:masters"]
    },
    {
      rolearn  = data.aws_iam_role.terraform_cloud_admin.arn
      username = "tfcloudadmin"
      groups   = ["system:masters"]
    }
  ]

  # ensure admin roles can access kms key
  kms_key_administrators = [data.aws_iam_role.aws_sso_admin.arn,
    data.aws_iam_role.terraform_cloud_admin.arn]

  tags = {
    Terraform   = "true"
  }
}

# Create a kubernetes provider for this cluster to be used by other components
# REQUIRED: This block is necessary to get aws-auth map to work
provider "kubernetes" {
  host                   = module.eks_cluster.cluster_endpoint
  cluster_ca_certificate = base64decode(module.eks_cluster.cluster_certificate_authority_data)
  token                  = data.aws_eks_cluster_auth.eks_cluster.token
}

