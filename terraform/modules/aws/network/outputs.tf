output "boot_key_name" {
  value = "${var.key_name}"
}

# VPC
output "vpc_id" {
  value = "${module.vpc.vpc_id}"
}

output "vpc_cidr" {
  value = "${module.vpc.vpc_cidr}"
}

output "vpc_s3_endpoint_id" {
  value = "${module.vpc.vpc_s3_endpoint_id}"
}

# Security Group
output "sg_allow_ssh_from_anywhere_id" {
  value = "${aws_security_group.allow_ssh_from_anywhere.id}"
}

output "sg_allow_es_from_anywhere_id" {
  value = "${aws_security_group.allow_es_from_anywhere.id}"
}

output "sg_allow_kibana_from_anywhere_id" {
  value = "${aws_security_group.allow_kibana_from_anywhere.id}"
}

output "sg_allow_https_from_anywhere_id" {
  value = "${aws_security_group.allow_https_from_anywhere.id}"
}

# Subnets
output "public_subnet_ids" {
  value = "${module.public_subnet.subnet_ids}"
}

output "private_subnet_ids" {
  value = "${module.private_subnet.subnet_ids}"
}

# Bastion
output "bastion_user" {
  value = "${module.bastion.user}"
}

output "bastion_private_ip" {
  value = "${module.bastion.private_ip}"
}

output "bastion_public_ip" {
  value = "${module.bastion.public_ip}"
}

# NAT
output "nat_gateway_ids" {
  value = "${module.nat.nat_gateway_ids}"
}

# Route53
output "sa_dns_domain" {
  value = "${var.sa_dns_domain}"
}

# S3
output "s3_sa_demo_gallery_bucket_id" {
  value = "${module.s3.s3_sa_demo_gallery_bucket_id}"
}

# ACM
#output "sa_dynamodb_amazon_com_cert_arn" {
  #value = "${data.aws_acm_certificate.env_sa_dynamodb_amazon_com.arn}"
#}

# ECS
#output "ecs_cluster_id" {
#  value = "${module.ecs.ecs_cluster_id}"
#}

