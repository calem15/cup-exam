resource "aws_iam_role" "default-ec2-role" {
  name = "default-ec2-role"
  assume_role_policy = "${data.aws_iam_policy_document.default-ec2-role-assume.json}"
}

resource "aws_iam_instance_profile" "ec2-instance-profile" {
  name = "default-ec2-instance-profile"
  path = "/"
  role = "${aws_iam_role.default-ec2-role.name}"
}

resource "aws_iam_role_policy_attachment" "ssm-ec2" {
  role = "${aws_iam_role.default-ec2-role.name}"
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

data "aws_iam_policy_document" "default-ec2-role-assume" {
  statement {
    effect = "Allow"
    actions = [ "sts:AssumeRole" ]
    principals {
      type = "Service"
      identifiers = [ "ec2.amazonaws.com" ]
    }
  }
}

locals {
  name = "monitoring"
  user_data = <<-EOT
  #!/bin/bash
  set -euxo pipefail

  # Update system and install dependencies
  sudo yum update -y
  sudo amazon-linux-extras enable python3.8
  sudo yum install -y python3.8

  # Install Docker
  sudo amazon-linux-extras install docker -y
  sudo service docker start
  sudo usermod -a -G docker ec2-user

  # Install Docker Compose
  sudo curl -L "https://github.com/docker/compose/releases/download/v2.31.0/docker-compose-$(uname -s)-$(uname -m)" -o /usr/bin/docker-compose
  sudo chmod +x /usr/bin/docker-compose

  # Install Python dependencies
  pip3.8 install --upgrade pip
  pip3.8 install ansible docker requests urllib3==2.2.3
  EOT
}

resource "aws_security_group" "monitoring_sg" {
  vpc_id = module.main_vpc.vpc_id

  ingress {
    description = "Allow inbound to VPC Subnet"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["10.1.0.0/16"]
  }

  egress {
    description = "Allow HTTP to application subnets"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "${local.name}-SG"
  }
}

data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]
  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}

module "ec2_instance_prometheus" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  version = "~> 3.0"

  name = "${local.name}Prometheus"

  ami                    = data.aws_ami.amazon_linux.id
  instance_type          = "t3.large"
  key_name               = "tf-keypair"
  monitoring             = true
  vpc_security_group_ids = [aws_security_group.monitoring_sg.id]
  subnet_id              = module.main_vpc.private_subnets[1]
  user_data_base64       = base64encode(local.user_data)
  enable_volume_tags     = false
  iam_instance_profile   = "default-ec2-instance-profile"
  root_block_device = [
    {
      encrypted   = false
      volume_type = "gp3"
      throughput  = 200
      volume_size = 50
      tags = {
        Name = "${local.name}-prometheus-root-block"
      }
    },
  ]

  ebs_block_device = [
    {
      device_name = "/dev/sdf"
      volume_type = "gp3"
      volume_size = 100
      throughput  = 200
      encrypted   = false
    }
  ]
  tags = {
    Name = "${local.name}Prometheus"
  }
}