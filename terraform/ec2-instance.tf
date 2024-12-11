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
  name = "monitoring-infra"
  user_data = <<-EOT
  #!/bin/bash
  echo "Hello Terraform!"
  echo "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQC9hz2/HKXNUBGvF7FUKA+Z89ae4kSe1C0ia/DdxdDZZ5f1Iy6k3a7SaX+dVRXh5x54XuTXUSCHA4u7mMc8Q6rBNYZSHFRmsiittTSW6WjcZIxnL6zsawnIjlCSFWpxh+MUfgSSUPQKS304M08kXwruAnjmvmNod2hfCVNId4xZIVNzog+NSzyDQszFQD7uQVwZAR8vjPS0AkxLjwTpm4kWvEEUnrnXHU3rK4Lcrz8AAtYCT8Rtb0JwGbpp9SJnZzdZAr231SQYD0cQ3Zq0APSRAaArPcD79kW3Xhs3rEybEIAhyxJUSfS/2QHkyVg4A+vqG3uxfuq5el6UHqt4buYUa8h8zwlEdCyfPlQCWijWbbRBunvKswo7iwc00AG55+tcVsfu7X96g5BqCfAzWQNrvmxytYPRp+3TuRt/qzvDcoSYt206+xgt8kHukNkBIEdxwADTdE/jF1uAbHzf3kyw93L0mp6LJfvufESqTPqFWmOpXn6U8IZW+go4GyEP5L0= jrobes@MacBook-Pro.local" >> ~/.ssh/authorized_keys
  sudo mkfs -t xfs /dev/sdf
  sudo mkdir /data
  sudo su
  echo "UUID=$(lsblk -o +UUID | grep nvme1n1 | awk -F' ' '{ print $7 }')  /data  xfs  defaults,nofail  0  2" >> /etc/fstab
  mount -a
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

  name = "${local.name}-prometheus"

  ami                    = data.aws_ami.amazon_linux.id
  instance_type          = "t3.large"
  key_name               = "tf-keypair"
  monitoring             = true
  vpc_security_group_ids = [aws_security_group.monitoring_sg.id]
  subnet_id              = module.main_vpc.private_subnets[0]
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
    Name = "${local.name}-prometheus"
  }
}