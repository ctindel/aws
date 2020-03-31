variable "name" {}
variable "env" {}

variable "owned_by" {}

variable "ec2_instance_type" {}
variable "security_group_id" {}
variable "sa_dns_domain" {}
variable "s3_sa_bucket" {}
variable "s3_sa_bucket_demos_prefix" {}

variable "region" {}

variable "vpc_id" {}
variable "vpc_public_subnet_ids" {
  type = "list"
}

variable "key_name" {}

variable "r53_domain" {}
variable "r53_zone_id" {}
