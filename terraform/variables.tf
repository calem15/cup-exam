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
    type = string
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
variable "cup_alb_prefix" {
  type = string
  description = "ALB prefix to be added to the name"
}
variable "cup_ec2_prefix" {
  type = string
  description = "EC2 prefix to be added to the name"
}
variable "cup_cf_prefix" {
  type = string
  description = "CloudFront prefix to be added to the name"
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
variable "grafana_int_port" {}
variable "whitelist_ip" {
    type = list(string)
    description = "Whitelisted IPs"
}