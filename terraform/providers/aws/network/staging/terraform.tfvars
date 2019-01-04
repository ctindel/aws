##### GENERAL

env = "staging"

name = "sa-demo"

boot_key_name = "sa-demo-bootkey-20161115"

##### NETWORK

vpc_cidr = "10.20.0.0/16"

azs = ["us-east-2a", "us-east-2b", "us-east-2c"]

private_subnets = ["10.20.0.0/19", "10.20.32.0/19", "10.20.64.0/19"]

public_subnets = ["10.20.128.0/20", "10.20.144.0/20", "10.20.160.0/20"]

bastion_instance_type = "t2.micro"

ecs_instance_type = "m4.xlarge"
ecs_instance_ebs_size = "1024"
