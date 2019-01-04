output "s3_sa_demo_gallery_bucket_id" {
  value = "${aws_s3_bucket.s3_sa_demo_gallery_bucket.id}"
}

output "s3_sa_demo_gallery_bucket_website_domain" {
  value = "${aws_s3_bucket.s3_sa_demo_gallery_bucket.website_domain}"
}

output "s3_sa_demo_gallery_bucket_hosted_zone_id" {
  value = "${aws_s3_bucket.s3_sa_demo_gallery_bucket.hosted_zone_id}"
}
