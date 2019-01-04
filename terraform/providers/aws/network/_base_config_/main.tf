provider "aws" {
  region = "${var.region}"
}

data "terraform_remote_state" "sa_demo_global" {
  backend = "s3"

  config {
    region  = "${var.region}"
    bucket  = "sa.dynamodb.amazon.com-${var.region}"
    key     = "demos/terraform/env/global/terraform.tfstate"
  }
}

terraform {
  backend "s3" {
    # Config is given as command line options in init.sh
  }
}

resource "aws_key_pair" "boot_key" {
  key_name   = "${var.boot_key_name}-${var.env}"
  public_key = "${file("../../../../../ssh/${var.boot_key_name}.id_rsa.pub")}"

  lifecycle {
    create_before_destroy = true
  }
}

module "network" {
  source = "../../../../modules/aws/network"

  name                         = "${var.name}"
  env                          = "${var.env}"
  owned_by                     = "${data.terraform_remote_state.sa_demo_global.owned_by}"
  vpc_cidr                     = "${var.vpc_cidr}"
  azs                          = "${var.azs}"
  region                       = "${var.region}"
  private_subnets              = "${var.private_subnets}"
  public_subnets               = "${var.public_subnets}"
  key_name                     = "${aws_key_pair.boot_key.key_name}"
  r53_domain                   = "${data.terraform_remote_state.sa_demo_global.r53_domain}"
  r53_zone_id                  = "${data.terraform_remote_state.sa_demo_global.r53_zone_id}"
  sa_dns_domain                = "${var.env}.${data.terraform_remote_state.sa_demo_global.r53_domain}"
  s3_sa_bucket                 = "${data.terraform_remote_state.sa_demo_global.s3_sa_bucket}"

  bastion_instance_type = "${var.bastion_instance_type}"
#  ecs_instance_type = "${var.ecs_instance_type}"
#  ecs_instance_ebs_size = "${var.ecs_instance_ebs_size}"
}
