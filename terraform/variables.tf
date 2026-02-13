variable "project_name" {
  description = "Project name, used for default tags and resource naming"
  type        = string
  default     = "linux-ops"
}

variable "environment" {
  description = "Deployment environment (dev, staging, prod)"
  type        = string
  default     = "dev"

  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "environment must be one of: dev, staging, prod"
  }
}

variable "aws_region" {
  description = "AWS region untuk deploy resources"
  type        = string
  default     = "ap-southeast-3"
}

variable "aws_profile" {
  description = "AWS profile untuk authentication"
  type        = string
  default     = "default"
}

variable "key_pair_name" {
  description = "Nama untuk AWS key pair"
  type        = string
  default     = "admin-key"
}

variable "public_key" {
  description = "SSH public key untuk key pair"
  type        = string
  sensitive   = true
}

variable "security_group_name" {
  description = "Nama untuk security group"
  type        = string
  default     = "allow-ssh"
}

variable "ssh_allowed_cidr" {
  description = "CIDR block yang diizinkan untuk SSH access"
  type        = string
  default     = "0.0.0.0/0"

  validation {
    condition     = can(cidrhost(var.ssh_allowed_cidr, 0))
    error_message = "ssh_allowed_cidr must be a valid CIDR block (e.g. 203.0.113.0/24)"
  }
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.micro"
}

variable "instance_name" {
  description = "Tag Name untuk EC2 instance"
  type        = string
  default     = "linux-ops"
}

variable "ubuntu_ami_owner" {
  description = "Owner ID untuk Ubuntu AMI (Canonical)"
  type        = string
  default     = "099720109477"
}

variable "ubuntu_version" {
  description = "Ubuntu version untuk AMI filter"
  type        = string
  default     = "ubuntu-jammy-22.04"
}

variable "s3_bucket_name" {
  description = "Nama S3 bucket untuk backup"
  type        = string
  default     = "linux-ops-bucket"
}

variable "s3_lifecycle_transition_days" {
  description = "Hari sebelum objek di-transition ke Glacier"
  type        = number
  default     = 30

  validation {
    condition     = var.s3_lifecycle_transition_days > 0
    error_message = "s3_lifecycle_transition_days must be greater than 0"
  }
}

variable "s3_lifecycle_noncurrent_transition_days" {
  description = "Hari sebelum versi noncurrent di-transition ke Glacier"
  type        = number
  default     = 7

  validation {
    condition     = var.s3_lifecycle_noncurrent_transition_days > 0
    error_message = "s3_lifecycle_noncurrent_transition_days must be greater than 0"
  }
}

variable "s3_lifecycle_noncurrent_expiration_days" {
  description = "Hari sebelum versi noncurrent dihapus"
  type        = number
  default     = 60

  validation {
    condition     = var.s3_lifecycle_noncurrent_expiration_days > 0
    error_message = "s3_lifecycle_noncurrent_expiration_days must be greater than 0"
  }
}

variable "iam_backup_user" {
  description = "IAM user yang diberi akses ke S3 backup bucket"
  type        = string
  default     = "inituser"
}

variable "ec2_root_volume_size" {
  description = "Root EBS volume size in GB"
  type        = number
  default     = 20

  validation {
    condition     = var.ec2_root_volume_size >= 8
    error_message = "ec2_root_volume_size must be at least 8 GB (Ubuntu minimum)"
  }
}

variable "ec2_root_volume_type" {
  description = "Root EBS volume type (gp3 recommended over gp2)"
  type        = string
  default     = "gp3"

  validation {
    condition     = contains(["gp2", "gp3", "io1", "io2"], var.ec2_root_volume_type)
    error_message = "ec2_root_volume_type must be one of: gp2, gp3, io1, io2"
  }
}
