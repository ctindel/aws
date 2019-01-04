variable "name" {
  default = "nat"
}

variable "azs" {
  type = "list"
}

variable "public_subnet_ids" {
  type = "list"
}
