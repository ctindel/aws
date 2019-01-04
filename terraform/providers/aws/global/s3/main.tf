resource "aws_iam_role" "s3_sa_bucket_replication" {
  name               = "sa-demo-${var.s3_sa_bucket_prefix}-repl-role"
  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "s3.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
POLICY
}

resource "aws_iam_policy" "s3_sa_bucket_replication" {
    name = "sa-demo-${var.s3_sa_bucket_prefix}-repl-policy"
    policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "s3:GetReplicationConfiguration",
        "s3:ListBucket"
      ],
      "Effect": "Allow",
      "Resource": [
        "${aws_s3_bucket.s3_sa_bucket.arn}"
      ]
    },
    {
      "Action": [
        "s3:GetObjectVersion",
        "s3:GetObjectVersionAcl"
      ],
      "Effect": "Allow",
      "Resource": [
        "${aws_s3_bucket.s3_sa_bucket.arn}/*"
      ]
    },
    {
      "Action": [
        "s3:ReplicateObject",
        "s3:ReplicateDelete"
      ],
      "Effect": "Allow",
      "Resource": "${aws_s3_bucket.s3_sa_bucket_replica.arn}/*"
    }
  ]
}
POLICY
}

resource "aws_iam_policy_attachment" "replication" {
    name = "sa-demo-${var.s3_sa_bucket_prefix}-repl-policy-attachment"
    roles = ["${aws_iam_role.s3_sa_bucket_replication.name}"]
    policy_arn = "${aws_iam_policy.s3_sa_bucket_replication.arn}"
}

resource "aws_s3_bucket" "s3_sa_bucket" {
  bucket  = "${var.s3_sa_bucket_prefix}-${var.region}"
  acl     = "private"
  region  = "${var.region}"

  tags {
    Name = "${var.s3_sa_bucket_prefix}-${var.region}"
    owned-by = "${var.owned_by}"
  }
  versioning {
    enabled = true
  }
  force_destroy = false
  replication_configuration {
    role = "${aws_iam_role.s3_sa_bucket_replication.arn}"
    rules {
      id     = "s3_sa_bucket_replication_rule"
      prefix = ""
      status = "Enabled"

      destination {
        bucket        = "${aws_s3_bucket.s3_sa_bucket_replica.arn}"
        storage_class = "STANDARD"
      }
    }
  }
}

resource "aws_s3_bucket" "s3_sa_bucket_replica" {
  provider = "aws.region_backup"
  bucket  = "${var.s3_sa_bucket_prefix}-${var.region_backup}-replica"
  acl     = "private"
  region  = "${var.region_backup}"

  tags {
    Name = "${var.s3_sa_bucket_prefix}-${var.region_backup}-replica"
    purpose = "Replica of ${var.s3_sa_bucket_prefix}-${var.region}"
    owned-by = "${var.owned_by}"
  }
  versioning {
    enabled = true
  }
  force_destroy = true
}

resource "aws_s3_bucket" "s3_sa_logs_bucket" {
  bucket  = "${var.s3_sa_bucket_prefix}-${var.region}-logs"
  acl     = "private"
  region  = "${var.region}"

  tags {
    Name = "${var.s3_sa_bucket_prefix}-${var.region}-logs"
    Application = "ELB"
    owned-by = "${var.owned_by}"
  }
  versioning {
    enabled = false
  }
  force_destroy = true
  lifecycle_rule {
    id = "root"
    prefix = "/"
    enabled = true

    transition {
      days = 30 
      storage_class = "STANDARD_IA"
    }
    expiration {
      days = 31 
    }
  }
  policy = <<EOF
{
  "Id": "access_logs_policy_from_elb",
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "Stmt1429136633762",
      "Action": "s3:PutObject",
      "Effect": "Allow",
      "Resource": "arn:aws:s3:::${var.s3_sa_bucket_prefix}-${var.region}-logs/*",
      "Principal": {
        "AWS": "arn:aws:iam::${lookup(var.elb_account_id,var.region)}:root"
      }
    }
  ]
}
EOF
}

resource "aws_iam_role" "s3_sa_history_bucket_replication" {
  name               = "sa-demo-${var.s3_sa_bucket_prefix}-history-repl-role"
  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "s3.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
POLICY
}

resource "aws_iam_policy" "s3_sa_history_bucket_replication" {
    name = "sa-demo-${var.s3_sa_bucket_prefix}-history-repl-policy"
    policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "s3:GetReplicationConfiguration",
        "s3:ListBucket"
      ],
      "Effect": "Allow",
      "Resource": [
        "${aws_s3_bucket.s3_sa_history_bucket.arn}"
      ]
    },
    {
      "Action": [
        "s3:GetObjectVersion",
        "s3:GetObjectVersionAcl"
      ],
      "Effect": "Allow",
      "Resource": [
        "${aws_s3_bucket.s3_sa_history_bucket.arn}/*"
      ]
    },
    {
      "Action": [
        "s3:ReplicateObject",
        "s3:ReplicateDelete"
      ],
      "Effect": "Allow",
      "Resource": "${aws_s3_bucket.s3_sa_history_bucket_replica.arn}/*"
    }
  ]
}
POLICY
}

resource "aws_iam_policy_attachment" "sa_demo_history_replication" {
    name = "sa-demo-${var.s3_sa_bucket_prefix}-history-repl-policy-attachment"
    roles = ["${aws_iam_role.s3_sa_history_bucket_replication.name}"]
    policy_arn = "${aws_iam_policy.s3_sa_history_bucket_replication.arn}"
}

resource "aws_s3_bucket" "s3_sa_history_bucket" {
  bucket  = "${var.s3_sa_bucket_prefix}-${var.region}-history"
  acl     = "private"
  region  = "${var.region}"

  tags {
    Name = "${var.s3_sa_bucket_prefix}-${var.region}-history"
    owned-by = "${var.owned_by}"
  }
  versioning {
    enabled = true
  }
  force_destroy = false
  lifecycle_rule {
    id = "root"
    prefix = "/"
    enabled = true

    transition {
      days = 30 
      storage_class = "STANDARD_IA"
    }
    expiration {
      days = 31 
    }
  }
  replication_configuration {
    role = "${aws_iam_role.s3_sa_history_bucket_replication.arn}"
    rules {
      id     = "s3_sa_history_bucket_replication_rule"
      prefix = ""
      status = "Enabled"

      destination {
        bucket        = "${aws_s3_bucket.s3_sa_history_bucket_replica.arn}"
        storage_class = "STANDARD"
      }
    }
  }
}

resource "aws_s3_bucket" "s3_sa_history_bucket_replica" {
  provider = "aws.region_backup"
  bucket  = "${var.s3_sa_bucket_prefix}-${var.region_backup}-history-replica"
  acl     = "private"
  region  = "${var.region_backup}"

  tags {
    Name = "${var.s3_sa_bucket_prefix}-${var.region_backup}-history-replica"
    purpose = "Replica of ${var.s3_sa_bucket_prefix}-${var.region}-history"
    owned-by = "${var.owned_by}"
  }
  versioning {
    enabled = true
  }
  force_destroy = true
  lifecycle_rule {
    id = "root"
    prefix = "/"
    enabled = true

    transition {
      days = 30 
      storage_class = "STANDARD_IA"
    }
    expiration {
      days = 31 
    }
  }
}
