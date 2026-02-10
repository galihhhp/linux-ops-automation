terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}

provider "aws" {
  region  = var.aws_region
  profile = var.aws_profile
}

resource "aws_key_pair" "admin" {
  key_name   = var.key_pair_name
  public_key = var.public_key
}

data "aws_vpc" "default" {
  filter {
    name   = "isDefault"
    values = ["true"]
  }
}

resource "aws_security_group" "main" {
  name   = var.security_group_name
  vpc_id = data.aws_vpc.default.id

  tags = {
    Name = var.security_group_name
  }
}

resource "aws_vpc_security_group_ingress_rule" "allow_ssh" {
  security_group_id = aws_security_group.main.id
  cidr_ipv4         = var.ssh_allowed_cidr
  from_port         = 22
  to_port           = 22
  ip_protocol       = "tcp"
}

resource "aws_vpc_security_group_egress_rule" "allow_all_traffic_ipv4" {
  security_group_id = aws_security_group.main.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}

data "aws_ami" "latest_ubuntu" {
  most_recent = true
  owners      = [var.ubuntu_ami_owner]

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/${var.ubuntu_version}-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

resource "aws_instance" "web" {
  ami           = data.aws_ami.latest_ubuntu.id
  instance_type = var.instance_type
  key_name      = aws_key_pair.admin.key_name

  vpc_security_group_ids = [aws_security_group.main.id]

  tags = {
    Name = var.instance_name
  }
}

data "aws_iam_policy_document" "s3_backup" {
  statement {
    sid    = "S3BackupFullAccess"
    effect = "Allow"
    actions = ["s3:*"]
    resources = [
      "arn:aws:s3:::${var.s3_bucket_name}",
      "arn:aws:s3:::${var.s3_bucket_name}/*"
    ]
  }
}

data "aws_iam_user" "backup" {
  user_name = var.iam_backup_user
}

resource "aws_iam_policy" "s3_backup" {
  name        = "S3BackupBucketPolicy"
  description = "Allow S3 bucket creation and backup operations"

  policy = data.aws_iam_policy_document.s3_backup.json
}

resource "aws_iam_user_policy_attachment" "s3_backup" {
  user       = data.aws_iam_user.backup.user_name
  policy_arn = aws_iam_policy.s3_backup.arn
}

resource "aws_s3_bucket" "main" {
  depends_on = [aws_iam_user_policy_attachment.s3_backup]
  bucket        = var.s3_bucket_name
  region        = var.aws_region
  force_destroy = true # learn purposes

  tags = {
    Name        = "Linux Ops Bucket"
    Environment = "Dev"
  }
}

resource "aws_s3_bucket_versioning" "versioning_main" {
  bucket = aws_s3_bucket.main.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "main" {
  bucket = aws_s3_bucket.main.id

  rule {
    id     = "backup-lifecycle"
    status = "Enabled"

    filter {}

    transition {
      days          = var.s3_lifecycle_transition_days
      storage_class = "GLACIER"
    }

    noncurrent_version_transition {
      noncurrent_days = var.s3_lifecycle_noncurrent_transition_days
      storage_class   = "GLACIER"
    }

    noncurrent_version_expiration {
      noncurrent_days = var.s3_lifecycle_noncurrent_expiration_days
    }
  }
}

resource "aws_s3_bucket_public_access_block" "main" {
  bucket = aws_s3_bucket.main.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

