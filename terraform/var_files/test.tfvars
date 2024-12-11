aws_azones = [
    "us-east-2a",
    "us-east-2b",
    "us-east-2c"
]
cidr_block = "10.1.0.0/16"
aws_api_prvt_subnet = [
    "10.1.96.0/19",
    "10.1.128.0/19",
    "10.1.160.0/19"
]
aws_data_prvt_subnet = [
    "10.1.0.0/20",
    "10.1.16.0/20",
    "10.1.32.0/20"
    ]
aws_web_pub_subnet = [
    "10.1.48.0/20",
    "10.1.64.0/20",
    "10.1.80.0/20"
]
whitelist_ip = [
    "10.1.0.0/16",
    "136.158.62.140/32"
]
cup_rds_prefix = "cup-rds-test"
cup_alb_prefix = "cup-alb-test"
cup_ec2_prefix = "cup-ec2-test"
cup_cf_prefix = "cup-cf-test"
cup_db_name = "postgres"
cup_db_user = "test"
cup_rds_min_cap = 1
cup_rds_max_cap = 2
grafana_int_port = 3000