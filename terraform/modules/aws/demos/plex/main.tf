data "aws_ami" "sa-demo-plex-ami" {
  most_recent = true
  filter {
    name = "name"
    values = ["sa-demo-${var.env}-ubuntu-base-16.04"]
  }
  owners = ["self"]
}

resource "aws_security_group" "sa-demo-plex-http-sg" {
  name        = "${var.name}-http-${var.env}-sg"
  description = "${var.name}-${var.env} http launch config security group"
  vpc_id      = "${var.vpc_id}"

  tags {
    Name       = "${var.name}-http-${var.env}-sg"
    managed-by = "terraform"
    owned-by   = "${var.owned_by}"
  }

  ingress {
    protocol    = "tcp"
    from_port   = 80 
    to_port     = 80
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "sa-demo-plex-sg" {
  name        = "${var.name}-${var.env}-sg"
  description = "${var.name}-${var.env} launch config security group"
  vpc_id      = "${var.vpc_id}"

  tags {
    Name       = "${var.name}-http-${var.env}-sg"
    managed-by = "terraform"
    owned-by   = "${var.owned_by}"
  }

  ingress {
    protocol    = "tcp"
    from_port   = 32400 
    to_port     = 32400
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_launch_configuration" "sa-demo-plex-lc" {
    name_prefix = "${var.name}-${var.env}"
    image_id = "${data.aws_ami.sa-demo-plex-ami.id}"
    instance_type = "${var.ec2_instance_type}"
    associate_public_ip_address = true
    key_name = "${var.key_name}"
    security_groups = [ "${var.security_group_id}", "${aws_security_group.sa-demo-plex-http-sg.id}", "${aws_security_group.sa-demo-plex-sg.id}" ]
    user_data = "${data.template_cloudinit_config.sa-demo-plex-user-data.rendered}"

    lifecycle {
        create_before_destroy = true
    }

    root_block_device {
        volume_type = "gp2"
        volume_size = "400"
    }
}

resource "aws_autoscaling_group" "sa-demo-plex-asg" {
    name = "${var.name}-${var.env}-asg"
    max_size = "1"
    min_size = "1"
    health_check_grace_period = 300
    health_check_type = "EC2"
    desired_capacity = 1
    force_delete = false
    launch_configuration = "${aws_launch_configuration.sa-demo-plex-lc.name}"
    vpc_zone_identifier = ["${var.vpc_public_subnet_ids}"]

    tag {
        key = "Name"
        value = "${var.name}-${var.env}"
        propagate_at_launch = true
    }

    tag {
        key = "env"
        value = "${var.env}"
        propagate_at_launch = true
    }

    tag {
        key = "managed_by"
        value = "terraform"
        propagate_at_launch = true
    }

    tag {
        key = "owned-by"
        value = "${var.owned_by}"
        propagate_at_launch = true
    }
}

data "template_file" "sa-demo-plex-user-data" {
  template = "${file("${path.module}/user_data.yml")}"

  vars {
    aws_region = "${var.region}"
    env = "${var.env}"
    s3_sa_bucket = "${var.s3_sa_bucket}"
    s3_sa_bucket_demos_prefix = "${var.s3_sa_bucket_demos_prefix}"
    hostname = "${var.name}"
    sa_dns_domain = "${var.sa_dns_domain}"
    setup_storage_sh = "${file("${path.module}/setup_storage.sh")}"
    install_plex_sh = "${file("${path.module}/install_plex.sh")}"
  }
}

# Render a multi-part cloudinit config making use of the part
# above, and other source files
data "template_cloudinit_config" "sa-demo-plex-user-data" {
  gzip          = true
  base64_encode = true

  part {
    content_type = "text/cloud-config"
    content      = "${data.template_file.sa-demo-plex-user-data.rendered}"
  }
}
