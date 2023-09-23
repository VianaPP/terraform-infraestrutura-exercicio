terraform {
    required_version = ">= 0.12"
}

provider "aws" {
    region = var.aws_region
}

variable "test_ip_address" {
    type = string
}

variable "aws_region" {
    type = string
}

variable "vpc_id" {
    type = string
}

variable "key_name" {
    type = string
}

resource "aws_vpc" "test_vpc" {
  cidr_block = "10.0.0.0/16"
}

resource "aws_internet_gateway" "test_igw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "test_igw"
  }
}

resource "aws_subnet" "test_subnet" {
  vpc_id   = aws_vpc.main.id
  cidr_block = "10.0.1.0/22"

  tags = {
    Name = "test_subnet"
  }
}

resource "aws_security_group" "test_sg" {
  name        = "test_sg"
  description = "VPC acess Internet"
  vpc_id      = var.vpc_id

  ingress {
    description      = "Allow from Personal CIDR block"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ${var.test_ip_address}/24
  }

  tags = {
    Name = "test_sg"
  }
}


resource "aws_instance" "test_instance" {
  ami             = ami-0c44b239cbfafe2f9
  instance_type   = "t3.small" 
  key_name        = var.key_name
  subnet_id       = aws_subnet.test_subnet.id
  vpc_security_group_ids = [aws_security_group.test_sg.id ]
 
  tags = {
    Name = "EC2"
  }
}