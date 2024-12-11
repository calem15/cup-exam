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
    type = string
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