module "main_vpc" {
  # source = "terraform-aws-modules/vpc/aws"
  source = "terraform-aws-modules/vpc/aws"
  name = "cup-vpc-test"
  cidr = var.cidr_block

  azs             = var.aws_azones
  private_subnets = var.aws_api_prvt_subnet
  public_subnets  = var.aws_web_pub_subnet
  database_subnets = var.aws_data_prvt_subnet
  enable_nat_gateway = true
  enable_vpn_gateway = false

  tags = {
    SERVICE = "MAIN NETWORK"
  }
}