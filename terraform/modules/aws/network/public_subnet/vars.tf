variable "name" {
  default = "public"
}

variable "env" {}

variable "owned_by" {}

variable "vpc_id" {}

variable "cidrs" {
  type = "list"
}

variable "azs" {
  type = "list"
}

