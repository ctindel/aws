data "aws_ami" "sa-demo-ecs-ami" {
  most_recent = true
  filter {
    name = "name"
    values = ["sa-demo-${var.env}-ubuntu-base-16.04"]
  }
  owners = ["self"]
}

resource "aws_ecs_cluster" "sa-demo-ecs" {
  name = "${var.name}-${var.env}"
}

resource "aws_iam_role" "sa-demo-ecs-role" {
  name               = "${var.name}-${var.env}-role"
  assume_role_policy = "${file("${path.module}/policies/ecs-role.json")}"
}

resource "aws_iam_instance_profile" "sa-demo-ecs-profile" {
  name = "${var.name}-${var.env}-instance-profile"
  path = "/"
  role = "${aws_iam_role.sa-demo-ecs-role.name}"
}

resource "aws_iam_role_policy" "sa-demo-ecs-service-role-policy" {
  name     = "${var.name}-${var.env}-service-role-policy"
  policy   = "${file("${path.module}/policies/ecs-service-role-policy.json")}"
  role     = "${aws_iam_role.sa-demo-ecs-role.id}"
}

resource "aws_iam_role_policy" "sa-demo-ecs-instance-role-policy" {
  name     = "${var.name}-${var.env}-instance-role-policy"
  policy   = "${file("${path.module}/policies/ecs-instance-role-policy.json")}"
  role     = "${aws_iam_role.sa-demo-ecs-role.id}"
}

resource "aws_cloudwatch_log_group" "sa-demo-ecs-log-group" {
  name = "sa-demo-ecs-logs-${var.env}"

  tags {
    Name = "sa-demo-ecs-logs-${var.env}"
    env = "${var.env}"
    managed_by = "terraform"
    owned-by = "${var.owned_by}"
  }
}

resource "aws_launch_configuration" "sa-demo-ecs-instance1-lc" {
    name_prefix = "${var.name}-instance1-${var.env}"
    image_id = "${data.aws_ami.sa-demo-ecs-ami.id}"
    instance_type = "${var.ecs_instance_type}"
    iam_instance_profile = "${aws_iam_instance_profile.sa-demo-ecs-profile.id}"
    associate_public_ip_address = true
    key_name = "${var.key_name}"
    security_groups = [
      "${split(",", var.instance_security_group_ids)}"
    ]
    user_data = "${data.template_cloudinit_config.sa-demo-ecs-instance1-user-data.rendered}"

    lifecycle {
        create_before_destroy = true
    }

    root_block_device {
        volume_type = "gp2"
        volume_size = "8"
    }

    ephemeral_block_device {
        device_name  = "/dev/sdb"
        virtual_name = "ephemeral0"
    }

    ebs_block_device = {
        device_name = "/dev/sdm"
        volume_type = "io1"
        volume_size = "${var.ecs_instance_ebs_size}"
        iops = "2000"
    }
}


resource "aws_autoscaling_group" "sa-demo-ecs-instance1-asg" {
    name = "${var.name}-instance1-${var.env}-asg"
    max_size = "1"
    min_size = "1"
    health_check_grace_period = 300
    health_check_type = "EC2"
    desired_capacity = 1
    force_delete = false
    launch_configuration = "${aws_launch_configuration.sa-demo-ecs-instance1-lc.name}"
    vpc_zone_identifier = ["${var.vpc_public_subnet_ids[0]}"]

    tag {
        key = "Name"
        value = "${var.name}-instance1-${var.env}"
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

data "template_file" "sa-demo-ecs-instance1-user-data" {
  template = "${file("${path.module}/instance_user_data.yml")}"

  vars {
    aws_region = "${var.region}"
    env = "${var.env}"
    #s3_sa_bucket = "${var.s3_sa_bucket}"
    hostname = "${var.name}-instance1"
    sa_dns_domain = "${var.env}.sa.elastic.co"
    setup_ecs_agent_sh = "${file("${path.module}/setup_ecs_agent.sh")}"
  }
}

# Render a multi-part cloudinit config making use of the part
# above, and other source files
data "template_cloudinit_config" "sa-demo-ecs-instance1-user-data" {
  gzip          = true
  base64_encode = false

  part {
    content_type = "text/cloud-config"
    content      = "${data.template_file.sa-demo-ecs-instance1-user-data.rendered}"
  }
}

