output "owned_by" {
  value = "${var.owned_by}"
}

# Route53
output "r53_domain" {
  value = "${var.r53_domain}"
}

output "r53_zone_id" {
  value = "${var.r53_zone_id}"
}

# S3
output "s3_sa_bucket" {
  value = "${module.s3.s3_sa_bucket_id}"
}

output "s3_sa_bucket_replica" {
  value = "${module.s3.s3_sa_bucket_replica_id}"
}

output "s3_sa_logs_bucket" {
  value = "${module.s3.s3_sa_logs_bucket_id}"
}

output "s3_sa_history_bucket" {
  value = "${module.s3.s3_sa_history_bucket_id}"
}

output "s3_sa_history_bucket_replica" {
  value = "${module.s3.s3_sa_history_bucket_replica_id}"
}

output "s3_sa_bucket_demos_prefix" {
  value = "demos"
}
