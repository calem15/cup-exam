resource "aws_db_subnet_group" "subnet_grp" {
  name        = "${var.cup_rds_prefix}-subnetgrp"
  description = "For Aurora cluster ${terraform.workspace}"
  subnet_ids  = module.main_vpc.database_subnets
  tags = {
    "Name" = "${var.cup_rds_prefix}-subnetgrp"
    "PROJECT" = "${var.cup_rds_prefix}"
  }
}

resource "aws_db_parameter_group" "db_param" {
  name   = "${var.cup_rds_prefix}-dbparam"
  description = "RDS default RDS instance parameter group"
  family = "aurora-postgresql15"
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_rds_cluster_parameter_group" "db_cluster_param" {
  name        = "${var.cup_rds_prefix}-dbcluster-param"
  family      = "aurora-postgresql15"
  description = "RDS default cluster parameter group"
  lifecycle {
    create_before_destroy = true
    ignore_changes = [
      parameter
    ]
  }
}

data "aws_rds_engine_version" "postgresql" {
  engine  = "aurora-postgresql"
  version = "15.4"
}

resource "aws_security_group" "rds_sg" {
    name = "${var.cup_rds_prefix}-Postgres-SG"
    vpc_id = module.main_vpc.vpc_id


    ingress {
        description = "Allow inbound from VPC Subnet"
        from_port   = 5432
        to_port     = 5432
        protocol    = "tcp"
        cidr_blocks = var.cidr_block
    }

    egress {
        description = "Allow All Egress"
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks      = ["0.0.0.0/0"]
        ipv6_cidr_blocks = ["::/0"]
    }

    tags = {
            Name = "${var.cup_rds_prefix}-rds-instances-SG"
        }
}

resource "aws_rds_cluster" "rds_cluster" {
  cluster_identifier = "${var.cup_rds_prefix}-cluster"
  final_snapshot_identifier = "${var.cup_rds_prefix}-cluster-finalsnap"
  skip_final_snapshot = false
  backup_retention_period = 7
  engine             = data.aws_rds_engine_version.postgresql.engine
  engine_mode        = "provisioned"
  engine_version     = data.aws_rds_engine_version.postgresql.version
  database_name      = var.cup_db_name
  master_username    = var.cup_db_user
  master_password    = var.cup_db_pass
  availability_zones = var.aws_azones
  apply_immediately  = false
  deletion_protection = true
  port               = 5432
  db_cluster_parameter_group_name = aws_rds_cluster_parameter_group.db_cluster_param.name
  db_instance_parameter_group_name = aws_db_parameter_group.db_param.name
  db_subnet_group_name = aws_db_subnet_group.subnet_grp.name
  vpc_security_group_ids = ["${aws_security_group.rds_sg.id}"]
  serverlessv2_scaling_configuration {
    max_capacity = 2
    min_capacity = 4
  }
  timeouts {
    create = "30m"
    update = "30m"
    delete = "60m"
  }

  lifecycle {
    ignore_changes = [
      engine_version,
      availability_zones,
      cluster_identifier,
      master_password,
      db_cluster_parameter_group_name,
      db_instance_parameter_group_name
      ]
  }

  copy_tags_to_snapshot = true

  tags = {
    "PROJECT" = "${var.cup_rds_prefix}"
  }
}

resource "aws_rds_cluster_instance" "rds_instance" {
  cluster_identifier = aws_rds_cluster.rds_cluster.id
  identifier         = "${var.cup_rds_prefix}-instance"
  instance_class     = "db.serverless"
  engine             = aws_rds_cluster.rds_cluster.engine
  engine_version     = aws_rds_cluster.rds_cluster.engine_version
  monitoring_interval= 60
  apply_immediately  = false
  tags = {
    "PROJECT" = "${var.cup_rds_prefix}"
  }
  lifecycle {
    ignore_changes = [engine_version,cluster_identifier]
  }
}