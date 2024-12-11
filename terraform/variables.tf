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