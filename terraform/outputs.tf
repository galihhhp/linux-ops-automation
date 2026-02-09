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
