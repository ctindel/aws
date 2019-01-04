variable "env" {
  description = "The environment name (dev | staging | prod)."
}

variable "name" {
  description = "The environment name; used as a prefix when naming resources."
}

variable "region" {
  default = "us-east-2"
}

# When deployed, each key is automatically prefixed with the environment name.
# That way even if multiple environments use the same boot key, there won't be
# resource conflicts as far as Terraform is concerned.
variable "boot_key_name" {
  description = <<DESCRIPTION
The name of the SSH keypair to use when launching EC2 instances.
This should match one of the bootkeys in the following directory:
  `infra/terraform/providers/aws/bootkeys/`
...and should be the name of the file before the `.id_rsa.pub` extension.
Example: bootkey-20160826
DESCRIPTION
}

variable "vpc_cidr" {
  description = "The CIDR block for the VPC."
}

variable "azs" {
  type = "list"

  description = <<DESCRIPTION
The Availability Zones for the VPC.
AZs are region-specific. This should be a list.
Example: ["us-west-2a", "us-west-2b", "us-west-2c"]
DESCRIPTION
}

# Refer to `infra/docs/aws-network-design.md`
variable "private_subnets" {
  type = "list"

  description = <<DESCRIPTION
The private subnets to define for the VPC.
This should be a list matching the length of the defined `azs`.
That will ensure one private subnet per AZ.
Example: ["10.240.0.0/19", "10.240.32.0/19", "10.240.64.0/19"]
DESCRIPTION
}

# Refer to `infra/docs/aws-network-design.md`
variable "public_subnets" {
  type = "list"

  description = <<DESCRIPTION
The public subnets to define for the VPC.
This should be a list matching the length of the defined `azs`.
That will ensure one public subnet per AZ.
Example: ["10.240.128.0/20", "10.240.144.0/20", "10.240.160.0/20"]
DESCRIPTION
}

variable "bastion_instance_type" {
  description = <<DESCRIPTION
The type of instance to start for the bastion host.
Example: t2.micro
DESCRIPTION
}

#variable "ecs_instance_type" {
#  description = <<DESCRIPTION
#The type of instance to start for the ECS Instances.
#Example: t2.micro
#DESCRIPTION
#}
#
#variable "ecs_instance_ebs_size" {
#  description = <<DESCRIPTION
#The size in GB of EBS volume to allocate on ECS instances
#Example: 1024
#DESCRIPTION
#}
