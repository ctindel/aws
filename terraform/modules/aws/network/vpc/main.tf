resource "aws_vpc" "vpc" {
  cidr_block           = "${var.cidr}"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags {
    Name       = "${var.name}-${var.env}"
    managed-by = "terraform"
    owned-by   = "${var.owned_by}"
  }

  lifecycle {
    create_before_destroy = true
  }
}
