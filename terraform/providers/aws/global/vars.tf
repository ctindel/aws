variable "region" {
  default = "us-east-2"
}

variable "region_backup" {
  default = "us-west-2"
}

variable "owned_by" {
  default = "dynamodb-specialists-amer@amazon.com"
}

variable "r53_domain" {
  default = "sa.ctindel-aws.com"
}

variable "r53_zone_id" {
  default = "Z2FCGJSOHFGZ2Q"
}

variable "s3_sa_bucket_prefix" {
  default = "sa.dynamodb.amazon.com"
  description = "The bucket name we store our demo stuff in"
}
