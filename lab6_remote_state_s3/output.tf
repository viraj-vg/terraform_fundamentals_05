output "instance_id" {
  description = "ID of the EC2 instance."
  value       = aws_instance.my_instance.id
}

output "instance_name" {
  description = "Name of the EC2 instance."
  value       = var.instance_name
}

