# S3
output "s3_sa_bucket_id" {
  value = "${aws_s3_bucket.s3_sa_bucket.id}"
}

output "s3_sa_bucket_replica_id" {
  value = "${aws_s3_bucket.s3_sa_bucket_replica.id}"
}

output "s3_sa_logs_bucket_id" {
  value = "${aws_s3_bucket.s3_sa_logs_bucket.id}"
}

output "s3_sa_history_bucket_id" {
  value = "${aws_s3_bucket.s3_sa_history_bucket.id}"
}

output "s3_sa_history_bucket_replica_id" {
  value = "${aws_s3_bucket.s3_sa_history_bucket_replica.id}"
}
