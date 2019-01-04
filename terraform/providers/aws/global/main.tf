# This is a placeholder global AWS configuration where we should defined things
# that are shared between the other environments. Resources like IAM users and
# policies, CloudTrail configurations, etc.

terraform {
  backend "s3" {
      bucket = "sa.dynamodb.amazon.com-us-east-2"
      key = "demos/terraform/env/global/terraform.tfstate"
      region = "us-east-2"
  }
}

provider "aws" {
  region = "${var.region}"
}

provider "aws" {
    alias = "region_backup"
    region = "${var.region_backup}"
}

module "s3" {
  source = "./s3"

  region              = "${var.region}"
  region_backup       = "${var.region_backup}"
  owned_by            = "${var.owned_by}"
  s3_sa_bucket_prefix = "${var.s3_sa_bucket_prefix}"
}
