resource "aws_route53_record" "s3_sa_demo_gallery_alias" {
  zone_id = "${var.r53_zone_id}"
  name = "demo.${var.sa_dns_domain}"
  type = "A"

  alias {
    name = "${var.s3_sa_demo_gallery_bucket_website_domain}"
    zone_id = "${var.s3_sa_demo_gallery_bucket_hosted_zone_id}"
    evaluate_target_health = false
  }
}
