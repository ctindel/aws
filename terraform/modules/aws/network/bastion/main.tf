resource "aws_security_group" "bastion" {
  name        = "${var.name}-bastion-${var.env}"
  vpc_id      = "${var.vpc_id}"
  description = "bastion host security group"

  tags {
    Name       = "${var.name}-bastion-${var.env}"
    managed-by = "terraform"
    owned-by   = "${var.owned_by}"
  }

  ingress {
    protocol    = -1
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["${var.vpc_cidr}"]
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

# Amazon Linux AMI <latest> x86_64 HVM GP2
data "aws_ami" "bastion_ami" {
  most_recent = true

  filter {
    name   = "name"
    values = ["amzn-ami-hvm*"]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }

  owners = ["amazon"]
}

resource "aws_instance" "bastion" {
  ami                         = "${data.aws_ami.bastion_ami.id}"
  instance_type               = "${var.instance_type}"
  subnet_id                   = "${var.public_subnet_ids[count.index]}"
  key_name                    = "${var.key_name}"
  vpc_security_group_ids      = ["${aws_security_group.bastion.id}"]
  associate_public_ip_address = true

  tags {
    Name       = "${var.name}-${var.env}"
    owned-by   = "${var.owned_by}"
  }

  lifecycle {
    create_before_destroy = true
    ignore_changes        = ["ami", "tags.%", "tags.Name"]
  }
}

# the provisioner block is in a separate resource (rather than within the
# instance declaration above) to force this to run even on existing resources
resource "null_resource" "set_bastion_name_tag" {
  provisioner "local-exec" {
    command = "aws ec2 create-tags --region ${var.region} --resources ${aws_instance.bastion.id} --tags Key=Name,Value='bastion-${replace(aws_instance.bastion.id, "/^i-/", "")}.${var.name}-${var.env}.${aws_instance.bastion.availability_zone}.elastic.co'"
  }
}

resource "aws_eip" "bastion" {
  vpc = true
}

resource "aws_eip_association" "eip_assoc" {
  instance_id   = "${aws_instance.bastion.id}"
  allocation_id = "${aws_eip.bastion.id}"
}
