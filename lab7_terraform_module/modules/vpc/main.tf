provider "aws" {
  region = "ap-south-1"
}

resource "aws_vpc" "my_vpc" {
  cidr_block = var.vpc_cidr

  tags = {
    Name = var.vpc_name
  }
}

resource "aws_subnet" "public_subnet1" {
  vpc_id            = aws_vpc.my_vpc.id
  cidr_block        = var.public_subnet1_cidr
  availability_zone = "ap-south-1a"

  tags = {
    Name = var.public_subnet1_name
  }
}

resource "aws_subnet" "public_subnet2" {
  vpc_id            = aws_vpc.my_vpc.id
  cidr_block        = var.public_subnet2_cidr
  availability_zone = "ap-south-1b"

  tags = {
    Name = var.public_subnet2_name
  }
}

resource "aws_internet_gateway" "my_igw" {
  vpc_id = aws_vpc.my_vpc.id
}

output "vpc_id" {
  value = aws_vpc.my_vpc.id
}

output "public_subnet_id" {
  value = aws_subnet.public_subnet1.id
}
