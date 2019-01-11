output "boot_key_name" {
  value = "${module.network.boot_key_name}"
}

# VPC
output "vpc_id" {
  value = "${module.network.vpc_id}"
}

output "vpc_cidr" {
  value = "${module.network.vpc_cidr}"
}

output "vpc_s3_endpoint_id" {
  value = "${module.network.vpc_s3_endpoint_id}"
}

# Security Group
output "sg_allow_ssh_from_anywhere_id" {
  value = "${module.network.sg_allow_ssh_from_anywhere_id}"
}

output "sg_allow_es_from_anywhere_id" {
  value = "${module.network.sg_allow_es_from_anywhere_id}"
}

output "sg_allow_kibana_from_anywhere_id" {
  value = "${module.network.sg_allow_kibana_from_anywhere_id}"
}

output "sg_allow_https_from_anywhere_id" {
  value = "${module.network.sg_allow_https_from_anywhere_id}"
}

# Subnets
output "public_subnet_ids" {
  value = "${module.network.public_subnet_ids}"
}

output "private_subnet_ids" {
  value = "${module.network.private_subnet_ids}"
}

# Bastion
output "bastion_user" {
  value = "${module.network.bastion_user}"
}

output "bastion_private_ip" {
  value = "${module.network.bastion_private_ip}"
}

output "bastion_public_ip" {
  value = "${module.network.bastion_public_ip}"
}

# NAT
output "nat_gateway_ids" {
  value = "${module.network.nat_gateway_ids}"
}

# Route53
output "sa_dns_domain" {
  value = "${module.network.sa_dns_domain}"
}

# S3
output "s3_sa_demo_gallery_bucket_id" {
  value = "${module.network.s3_sa_demo_gallery_bucket_id}"
}

# ACM
output "sa_dynamodb_amazon_com_arn" {
  value = "${module.network.sa_dynamodb_amazon_com_cert_arn}"
}

# ECS
#output "ecs_cluster_id" {
#  value = "${module.network.ecs_cluster_id}"
#}
