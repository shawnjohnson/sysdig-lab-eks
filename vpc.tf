
// Configures a vpc for my AWS account on the subnet of 10.0.0.0/16 with flow logs enabled to cloudwatch

# data "aws_iam_account_alias" "current" {}

data "aws_availability_zones" "available" {}

module "vpc" {
    source = "terraform-aws-modules/vpc/aws"
    # name = "${data.aws_iam_account_alias.current.account_alias}-vpc"
    name = "east-lab"
    cidr = "10.0.0.0/16"
    azs = ["${data.aws_availability_zones.available.names[0]}", 
           "${data.aws_availability_zones.available.names[1]}", 
           "${data.aws_availability_zones.available.names[2]}"]
    private_subnets = ["10.0.64.0/24", "10.0.65.0/24", "10.0.66.0/24"]
    public_subnets  = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
    database_subnets = ["10.0.192.0/24", "10.0.193.0/24", "10.0.194.0/24"]
    create_database_subnet_route_table = true

    enable_nat_gateway = false
    single_nat_gateway = false
    enable_vpn_gateway = false
    enable_dns_hostnames = true
    enable_dns_support = true
    enable_flow_log = false    
    tags = {
        Terraform = "true"
    }
}

module "nat" {
  source = "int128/nat-instance/aws"

  name                        = "sysdigdev"
  vpc_id                      = module.vpc.vpc_id
  public_subnet               = module.vpc.public_subnets[0]
  private_subnets_cidr_blocks = module.vpc.private_subnets_cidr_blocks
  private_route_table_ids     = module.vpc.private_route_table_ids
  use_spot_instance           = true
}

resource "aws_eip" "nat" {
  network_interface = module.nat.eni_id
  tags = {
    "Name" = "nat-sysdigdev"
  }
}