data "aws_ami" "sa-demo-cassandra-ami" {
  most_recent = true
  filter {
    name = "name"
    values = ["sa-demo-${var.env}-ubuntu-base-16.04"]
  }
  owners = ["self"]
}

resource "aws_launch_configuration" "sa-demo-cassandra-lc" {
    name_prefix = "${var.name}-${var.env}"
    image_id = "${data.aws_ami.sa-demo-cassandra-ami.id}"
    instance_type = "${var.ec2_instance_type}"
    associate_public_ip_address = true
    key_name = "${var.key_name}"
    security_groups = [ "${var.security_group_id}" ]
    user_data = "${data.template_cloudinit_config.sa-demo-cassandra-user-data.rendered}"

    lifecycle {
        create_before_destroy = true
    }

    root_block_device {
        volume_type = "gp2"
        volume_size = "100"
    }
}

resource "aws_autoscaling_group" "sa-demo-cassandra-asg" {
    name = "${var.name}-${var.env}-asg"
    max_size = "1"
    min_size = "1"
    health_check_grace_period = 300
    health_check_type = "EC2"
    desired_capacity = 1
    force_delete = false
    launch_configuration = "${aws_launch_configuration.sa-demo-cassandra-lc.name}"
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

data "template_file" "sa-demo-cassandra-user-data" {
  template = "${file("${path.module}/user_data.yml")}"

  vars {
    aws_region = "${var.region}"
    env = "${var.env}"
    s3_sa_bucket = "${var.s3_sa_bucket}"
    s3_sa_bucket_demos_prefix = "${var.s3_sa_bucket_demos_prefix}"
    hostname = "${var.name}"
    sa_dns_domain = "${var.sa_dns_domain}"
    start_cassandra_sh = "${file("${path.module}/start_cassandra.sh")}"
    ycsb_cassandra_service = "${file("${path.module}/ycsb_cassandra.service")}"
    ycsb_cassandra_runner = "${file("${path.module}/ycsb_cassandra_runner.sh")}"
  }
}

# Render a multi-part cloudinit config making use of the part
# above, and other source files
data "template_cloudinit_config" "sa-demo-cassandra-user-data" {
  gzip          = true
  base64_encode = true

  part {
    content_type = "text/cloud-config"
    content      = "${data.template_file.sa-demo-cassandra-user-data.rendered}"
  }
}
