resource "aws_neptune_subnet_group" "sa-demo-yelp-nsg" {
  name       = "main"
  subnet_ids = ["${var.vpc_public_subnet_ids}"]

  tags = {
    Name = "${var.name}-${var.env}-neptune-sg"
  }
}

resource "aws_neptune_cluster" "sa-demo-yelp-nc" {
  cluster_identifier = "${var.name}-${var.env}"
  engine                              = "neptune"
  backup_retention_period             = 5
  preferred_backup_window             = "07:00-09:00"
  skip_final_snapshot                 = true
  iam_database_authentication_enabled = true
  apply_immediately                   = true
  neptune_subnet_group_name           = "${aws_neptune_subnet_group.sa-demo-yelp-nsg.id}"
}
