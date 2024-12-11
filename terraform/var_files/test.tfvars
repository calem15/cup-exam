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
cup_rds_prefix = "cup-rds-test"
cup_db_name = "postgres"
cup_db_user = "test"
cup_db_pass = ${{ secrets.TF_VAR_DB_PASSWORD }}