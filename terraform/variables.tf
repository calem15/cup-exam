variable "aws_region" {
    type = string
    default = "us-east-1"
    description = "AWS default region"
}
variable "aws_profile" {
    type = string
    default = ""
    description = "AWS Profile to use accessing tfstate and tenants. Check your AWS profile settings."
}
variable "cidr_block" {
    type = list(string)
    description = "CIDR block for VPC"
}
variable "aws_azones" {
    type = list(string)
    description = "AWS Availability Zones"
}
variable "aws_api_prvt_subnet" {
    type = list(string)
    description = "AWS private subnet for APIs"
}
variable "aws_web_pub_subnet" {
    type = list(string)
    description = "AWS public subnet for Web"
}
variable "aws_data_prvt_subnet" {
    type = list(string)
    description = "AWS private subnet for Database"
}
variable "cup_rds_prefix" {
  type = string
  description = "RDS prefix to be added to the name"
}
variable "cup_db_name" {default = ""}
variable "cup_db_pass" {
  type = string
  sensitive = true
  default = ""
  }
variable "cup_db_user" {default = ""}
variable "cup_rds_min_cap" {}
variable "cup_rds_max_cap" {}