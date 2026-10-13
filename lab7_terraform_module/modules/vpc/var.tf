variable "vpc_name" {
  description = "The name of the VPC."
  type        = string
  default     = "module-vpc"
}

variable "vpc_cidr" {
  description = "The CIDR block for the VPC."
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnet1_name" {
  description = "The name of the first public subnet."
  type        = string
  default     = "module-public-subnet-1"
}

variable "public_subnet2_name" {
  description = "The name of the second public subnet."
  type        = string
  default     = "module-public-subnet-2"
}

variable "public_subnet1_cidr" {
  description = "The CIDR block for the first public subnet."
  type        = string
  default     = "10.0.1.0/24"
  
}

variable "public_subnet2_cidr" {
  description = "The CIDR block for the second public subnet."
  type        = string
  default     = "10.0.2.0/24"
}