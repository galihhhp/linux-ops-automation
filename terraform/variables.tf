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
  default     = "admin key"
}

variable "public_key" {
  description = "SSH public key untuk key pair"
  type        = string
  sensitive   = true
}

variable "security_group_name" {
  description = "Nama untuk security group"
  type        = string
  default     = "allow ssh"
}

variable "ssh_allowed_cidr" {
  description = "CIDR block yang diizinkan untuk SSH access"
  type        = string
  default     = "0.0.0.0/0"
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
