variable "name" {}

variable "env" {}

variable "owned_by" {}

variable "vpc_id" {}

variable "vpc_cidr" {}

variable "region" {}

variable "public_subnet_ids" {
  type = "list"
}

variable "key_name" {}

variable "instance_type" {}
