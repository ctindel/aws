variable "name" {}
variable "env" {}

variable "owned_by" {
}

variable "vpc_cidr" {}

variable "azs" {
  type = "list"
}

variable "region" {}

variable "private_subnets" {
  type = "list"
}

variable "public_subnets" {
  type = "list"
}

variable "key_name" {}

variable "bastion_instance_type" {}
#variable "ecs_instance_type" {}
#variable "ecs_instance_ebs_size" {}

variable "r53_domain" {}
variable "r53_zone_id" {}

variable "sa_dns_domain" {}

variable "s3_sa_bucket" { }
