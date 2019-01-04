variable "name" {}
variable "env" {}
variable "owned_by" {}

variable "region" {}

variable "vpc_id" {}
variable "vpc_public_subnet_ids" {
  type = "list"
}

variable "instance_security_group_ids" {}

variable "key_name" {}

variable "ecs_instance_type" {}
variable "ecs_instance_ebs_size" {}
