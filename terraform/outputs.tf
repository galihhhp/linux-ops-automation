output "ec2_public_ip" {
  description = "Public IP address dari EC2 instance"
  value       = aws_instance.web.public_ip
}

output "ec2_private_ip" {
  description = "Private IP address dari EC2 instance"
  value       = aws_instance.web.private_ip
}

output "ec2_instance_id" {
  description = "Instance ID dari EC2 instance"
  value       = aws_instance.web.id
}

output "ec2_instance_arn" {
  description = "ARN dari EC2 instance"
  value       = aws_instance.web.arn
}

output "key_pair_name" {
  description = "Nama key pair yang digunakan"
  value       = aws_key_pair.admin.key_name
}

output "security_group_id" {
  description = "ID dari security group"
  value       = aws_security_group.main.id
}

output "vpc_id" {
  description = "ID dari default VPC yang digunakan"
  value       = data.aws_vpc.default.id
}

output "vpc_cidr_block" {
  description = "CIDR block dari default VPC"
  value       = data.aws_vpc.default.cidr_block
}

output "ssh_command" {
  description = "Command untuk SSH ke EC2 instance"
  value       = "ssh -i <path-to-key> ubuntu@${aws_instance.web.public_ip}"
}

output "s3_bucket_name" {
  description = "Nama S3 bucket untuk backup"
  value       = aws_s3_bucket.main.id
}

output "s3_bucket_arn" {
  description = "ARN S3 bucket"
  value       = aws_s3_bucket.main.arn
}

output "s3_bucket_region" {
  description = "Region S3 bucket"
  value       = var.aws_region
}

output "iam_backup_user" {
  description = "IAM user dengan akses S3 backup"
  value       = data.aws_iam_user.backup.user_name
}

output "iam_backup_policy_arn" {
  description = "ARN policy S3 backup yang ter-attach ke IAM user"
  value       = aws_iam_policy.s3_backup.arn
}
