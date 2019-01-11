variable "name" {
  default = "private"
}

variable "env" {}

variable "owned_by" {}

variable "vpc_id" {}
variable "vpc_s3_endpoint_id" {}

variable "cidrs" {
  type = "list"
}

variable "azs" {
  type = "list"
}

variable "nat_gateway_ids" {
  type = "list"
}
