##### GENERAL

env = "prod"

name = "sa-demo"

boot_key_name = "sa-demo-bootkey-20161115"

##### NETWORK

vpc_cidr = "10.30.0.0/16"

azs = ["us-east-2a", "us-east-2b", "us-east-2c"]

private_subnets = ["10.30.0.0/19", "10.30.32.0/19", "10.30.64.0/19"]

public_subnets = ["10.30.128.0/20", "10.30.144.0/20", "10.30.160.0/20"]

bastion_instance_type = "t2.micro"

ecs_instance_type = "m4.xlarge"
ecs_instance_ebs_size = "1024"
