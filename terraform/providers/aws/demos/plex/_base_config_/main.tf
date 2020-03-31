provider "aws" {
  region = "${var.region}"
}

terraform {
  backend "s3" {
    # Config is given as command line options in init.sh
  }
}

data "terraform_remote_state" "sa_demo_global" {
  backend = "s3"

  config {
    region  = "${var.region}"
    bucket  = "sa.dynamodb.amazon.com-${var.region}"
    key     = "demos/terraform/env/global/terraform.tfstate"
  }
}

data "terraform_remote_state" "sa_demo_network" {
  backend = "s3"

  config {
    region  = "${var.region}"
    bucket  = "sa.dynamodb.amazon.com-${var.region}"
    key     = "demos/terraform/env/${var.env}/network/terraform.tfstate"
  }
}

module "plex" {
  source = "../../../../../modules/aws/demos/plex"

  env                                 = "${var.env}"
  name                                = "${var.name}"
  region                              = "${var.region}"
  ec2_instance_type                   = "${var.ec2_instance_type}"
  owned_by                            = "${var.owned_by}"
  vpc_id                              = "${data.terraform_remote_state.sa_demo_network.vpc_id}"
  vpc_public_subnet_ids               = "${data.terraform_remote_state.sa_demo_network.public_subnet_ids}"
  security_group_id                   = "${data.terraform_remote_state.sa_demo_network.sg_allow_ssh_from_anywhere_id}"
  key_name                            = "${data.terraform_remote_state.sa_demo_network.boot_key_name}"
  sa_dns_domain                       = "${var.env}.${data.terraform_remote_state.sa_demo_global.r53_domain}"
  s3_sa_bucket                        = "${data.terraform_remote_state.sa_demo_global.s3_sa_bucket}"
  s3_sa_bucket_demos_prefix           = "${data.terraform_remote_state.sa_demo_global.s3_sa_bucket_demos_prefix}"
  r53_domain                          = "${data.terraform_remote_state.sa_demo_network.r53_domain}"
  r53_zone_id                         = "${data.terraform_remote_state.sa_demo_network.r53_zone_id}"
}
