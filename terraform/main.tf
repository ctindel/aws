provider "aws" {
    region = "us-east-1"
}

data "terraform_remote_state" "aws_global" {
  backend = "s3"

  config {
    region  = "us-east-1"
    bucket  = "co.elastic.sa"
    key     = "demos/terraform/network/terraform.tfstate"
  }
}

resource "aws_vpc" "sa-demo-vpc" {
  cidr_block = "192.168.50.0/24"
  enable_dns_support = true
  enable_dns_hostnames = true

  tags {
    Name = "sa-demo-vpc"
  }
}

resource "aws_internet_gateway" "sa-demo-ig" {
  vpc_id = "${aws_vpc.sa-demo-vpc.id}"
  tags {
    Name = "sa-demo-ig"
  }
}

resource "aws_subnet" "sa-demo-subnet-us-east-1a" {
  vpc_id = "${aws_vpc.sa-demo-vpc.id}"
  cidr_block = "192.168.50.0/24"
  availability_zone = "us-east-1a"
  tags {
    Name = "sa-demo-subnet-us-east-1a"
  }
  map_public_ip_on_launch = true
}

resource "aws_route_table" "sa-demo-rt" {
  vpc_id = "${aws_vpc.sa-demo-vpc.id}"
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.sa-demo-ig.id}"
  }
  tags {
    Name = "sa-demo-rt"
  }
}

resource "aws_route_table_association" "sa-demo-us-east-1a-rtassn"
{
  subnet_id = "${aws_subnet.sa-demo-subnet-us-east-1a.id}"
  route_table_id = "${aws_route_table.sa-demo-rt.id}"
}

resource "aws_security_group" "sa-demo-sg" {
  name = "sa-demo-sg"
  description = "Allow inbound SSH traffic"
  vpc_id = "${aws_vpc.sa-demo-vpc.id}"

  ingress {
    from_port = 0
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
      from_port = 0
      to_port = 0
      protocol = -1
      cidr_blocks = ["0.0.0.0/0"]
  }
}

data "aws_ami" "sa-beats-demo-ami" {
  most_recent = true
  filter {
    name = "name"
    values = ["elastic-sa-demo-beats-generator"]
  }
  owners = ["self"]
}

resource "aws_launch_configuration" "sa-beats-demo-lc" {
    name_prefix = "sa-beats-demo-"
    image_id = "${data.aws_ami.sa-beats-demo-ami.id}"
    instance_type = "${var.ec2_instance_type}"
    associate_public_ip_address = true
    key_name = "ctindel_elastic"
    security_groups = [ "${aws_security_group.sa-demo-sg.id}" ]

    lifecycle {
        create_before_destroy = true
    }

    root_block_device {
        volume_type = "gp2"
        volume_size = "8"
    }
}

resource "aws_autoscaling_group" "sa-beats-demo-asg" {
    name = "sa-beats-demo-asg"
    max_size = "1"
    min_size = "1"
    health_check_grace_period = 300
    health_check_type = "EC2"
    desired_capacity = 1
    force_delete = false
    launch_configuration = "${aws_launch_configuration.sa-beats-demo-lc.name}"
    vpc_zone_identifier = [
        "${aws_subnet.sa-demo-subnet-us-east-1a.id}"
    ]

    tag {
        key = "Name"
        value = "sa-beats-demo"
        propagate_at_launch = true
    }

    tag {
        key = "Owner"
        value = "sa@elastic.co"
        propagate_at_launch = true
    }
}
