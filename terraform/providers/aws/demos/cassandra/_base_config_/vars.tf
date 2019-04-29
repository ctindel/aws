variable "env" {
  description = "The environment name (dev | staging | prod)."
}

variable "name" {
  description = "The demo name; used as a prefix when naming resources."
}

variable "owned_by" {
  default = "dynamodb-specialists-amer@amazon.com"
  description = <<DESCRIPTION
Ownership tag to apply to taggable resources.
The email address of the person responsible for the launched resources.
If you're running `terraform` commands, it's probably you.
DESCRIPTION
}

variable "region" {
  description = "The AWS region to launch/configure resources within."
}

variable "ec2_instance_type" {
  description = "The instance type to launch for the demo."
}
