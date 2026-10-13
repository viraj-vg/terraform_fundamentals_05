variable "instance_name" {
  description = "Value of the EC2 instance's Name tag."
  type        = string
  default     = "module-ec2-instance"
}

variable "instance_type" {
  description = "The EC2 instance's type."
  type        = string
  default     = "t3.micro"
}

variable "vpc_id" {
  description = "The VPC ID where the EC2 instance should be created."
  type        = string
}

variable "subnet_id" {
  description = "The subnet ID where the EC2 instance should be launched."
  type        = string
}
