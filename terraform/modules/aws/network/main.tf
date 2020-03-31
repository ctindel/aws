module "s3" {
  source = "./s3"

  region        = "${var.region}"
  name          = "${var.name}-s3"
  owned_by      = "${var.owned_by}"
  sa_dns_domain = "${var.sa_dns_domain}"
}

module "route53" {
  source = "./route53"

  env             = "${var.env}"
  region          = "${var.region}"
  name            = "${var.name}-s3"
  owned_by        = "${var.owned_by}"
  sa_dns_domain   = "${var.sa_dns_domain}"
  r53_zone_id     = "${var.r53_zone_id}"
  s3_sa_demo_gallery_bucket_website_domain = "${module.s3.s3_sa_demo_gallery_bucket_website_domain}"
  s3_sa_demo_gallery_bucket_hosted_zone_id = "${module.s3.s3_sa_demo_gallery_bucket_hosted_zone_id}"
}

module "vpc" {
  source = "./vpc"

  region   = "${var.region}"
  name     = "${var.name}-vpc"
  env      = "${var.env}"
  owned_by = "${var.owned_by}"
  cidr     = "${var.vpc_cidr}"
}

module "public_subnet" {
  source = "./public_subnet"

  name     = "${var.name}-public"
  env      = "${var.env}"
  owned_by = "${var.owned_by}"
  vpc_id   = "${module.vpc.vpc_id}"
  cidrs    = "${var.public_subnets}"
  azs      = "${var.azs}"
}

module "bastion" {
  source = "./bastion"

  name              = "${var.name}"
  env               = "${var.env}"
  owned_by          = "${var.owned_by}"
  vpc_id            = "${module.vpc.vpc_id}"
  vpc_cidr          = "${module.vpc.vpc_cidr}"
  region            = "${var.region}"
  public_subnet_ids = "${module.public_subnet.subnet_ids}"
  key_name          = "${var.key_name}"
  instance_type     = "${var.bastion_instance_type}"
}

#module "ecs" {
#  source = "./ecs"
#
#  name                        = "${var.name}-ecs"
#  env                         = "${var.env}"
#  owned_by                    = "${var.owned_by}"
#  region                      = "${var.region}"
#  vpc_id                      = "${module.vpc.vpc_id}"
#  vpc_public_subnet_ids       = "${module.public_subnet.subnet_ids}"
#  instance_security_group_ids = "${aws_security_group.allow_ssh_from_anywhere.id}"
#  key_name                    = "${var.key_name}"
#  ecs_instance_type           = "${var.ecs_instance_type}"
#  ecs_instance_ebs_size       = "${var.ecs_instance_ebs_size}"
#}

module "nat" {
  source = "./nat"

  name              = "${var.name}-nat"
  azs               = "${var.azs}"
  public_subnet_ids = "${module.public_subnet.subnet_ids}"
}

module "private_subnet" {
  source = "./private_subnet"

  name     = "${var.name}-private"
  env      = "${var.env}"
  owned_by = "${var.owned_by}"
  vpc_id   = "${module.vpc.vpc_id}"
  vpc_s3_endpoint_id = "${module.vpc.vpc_s3_endpoint_id}"
  cidrs    = "${var.private_subnets}"
  azs      = "${var.azs}"

  nat_gateway_ids = "${module.nat.nat_gateway_ids}"
}

resource "aws_network_acl" "acl" {
  vpc_id     = "${module.vpc.vpc_id}"
  subnet_ids = ["${concat(module.public_subnet.subnet_ids, module.private_subnet.subnet_ids)}"]

  ingress {
    protocol   = "-1"
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 0
  }

  egress {
    protocol   = "-1"
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 0
  }

  tags {
    Name       = "${var.name}-all"
    managed-by = "terraform"
    owned_by   = "${var.owned_by}"
  }
}

resource "aws_security_group" "allow_ssh_from_anywhere" {
  name        = "${var.name}-${var.env}-allow-ssh-from-anywhere-sg"
  description = "${var.name}-${var.env} VPC Allow ssh from anywhere security group"
  vpc_id      = "${module.vpc.vpc_id}"

  tags {
    Name       = "${var.name}-${var.env}-allow-ssh-from-anywhere-sg"
    managed-by = "terraform"
    owned_by   = "${var.owned_by}"
  }

  ingress {
    protocol    = "tcp"
    from_port   = 22
    to_port     = 22
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    protocol    = -1
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "allow_es_from_anywhere" {
  name        = "${var.name}-${var.env}-allow-es-from-anywhere"
  description = "${var.name}-${var.env} VPC Allow Elasticsearch from anywhere security group"
  vpc_id      = "${module.vpc.vpc_id}"

  tags {
    Name       = "${var.name}-${var.env}-allow-es-from-anywhere"
    managed-by = "terraform"
    owned-by   = "${var.owned_by}"
  }

  ingress {
    protocol    = "tcp"
    from_port   = 9243
    to_port     = 9243
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    protocol    = -1
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "allow_kibana_from_anywhere" {
  name        = "${var.name}-${var.env}-allow-kibana-from-anywhere"
  description = "${var.name}-${var.env} VPC Allow Kibana from anywhere security group"
  vpc_id      = "${module.vpc.vpc_id}"

  tags {
    Name       = "${var.name}-${var.env}-allow-kibana-from-anywhere"
    managed-by = "terraform"
    owned-by   = "${var.owned_by}"
  }

  ingress {
    protocol    = "tcp"
    from_port   = 5601
    to_port     = 5601
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    protocol    = -1
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "allow_http_from_anywhere" {
  name        = "${var.name}-${var.env}-allow-http-from-anywhere"
  description = "${var.name}-${var.env} VPC Allow HTTP from anywhere security group"
  vpc_id      = "${module.vpc.vpc_id}"

  tags {
    Name       = "${var.name}-${var.env}-allow-http-from-anywhere"
    managed-by = "terraform"
    owned-by   = "${var.owned_by}"
  }

  ingress {
    protocol    = "tcp"
    from_port   = 443
    to_port     = 443
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    protocol    = -1
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "allow_https_from_anywhere" {
  name        = "${var.name}-${var.env}-allow-https-from-anywhere"
  description = "${var.name}-${var.env} VPC Allow HTTPS from anywhere security group"
  vpc_id      = "${module.vpc.vpc_id}"

  tags {
    Name       = "${var.name}-${var.env}-allow-https-from-anywhere"
    managed-by = "terraform"
    owned-by   = "${var.owned_by}"
  }

  ingress {
    protocol    = "tcp"
    from_port   = 443
    to_port     = 443
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    protocol    = -1
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "allow_documentdb_from_anywhere" {
  name        = "${var.name}-${var.env}-allow-documentdb-from-anywhere-sg"
  description = "${var.name}-${var.env} VPC Allow documentdb from anywhere security group"
  vpc_id      = "${module.vpc.vpc_id}"

  tags {
    Name       = "${var.name}-${var.env}-allow-documentdb-from-anywhere-sg"
    managed-by = "terraform"
    owned_by   = "${var.owned_by}"
  }

  ingress {
    protocol    = "tcp"
    from_port   = 27017
    to_port     = 27017
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    protocol    = -1
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
}

#data "aws_acm_certificate" "env_sa_dynamodb_amazon_com" {
  #domain = "*.${var.env}.${var.r53_domain}"
  #statuses = ["ISSUED"]
#}
