resource "aws_s3_bucket" "s3_sa_demo_gallery_bucket" {
  bucket = "demo.${var.sa_dns_domain}"
  #acl = "public-read"
  acl    = "private"
  tags {
    Name = "demo.${var.sa_dns_domain}"
    owned-by = "${var.owned_by}"
  }
  versioning {
    enabled = true
  }
  force_destroy = true
  lifecycle {
    prevent_destroy = false
  }

  website {
    index_document = "index.html"
  }

#  policy = <<EOF
#{
#  "Version":"2012-10-17",
#  "Statement":[{
#    "Sid":"PublicReadForGetBucketObjects",
#    "Effect":"Allow",
#    "Principal": "*",
#    "Action":["s3:GetObject"],
#      "Resource":["arn:aws:s3:::demo.${var.sa_dns_domain}/*"]
#    }
#  ]
#}
#EOF

}
