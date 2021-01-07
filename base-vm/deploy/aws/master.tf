variable "ACCESS_KEY" {}
variable "SECRET_KEY" {}
variable "AMI_ID" {}
variable "REGION" {}
variable "private_subnet_cidr" {}
variable "availability_zones" {}


provider "aws" {
  access_key = var.ACCESS_KEY
  secret_key = var.SECRET_KEY
  region = var.REGION
}

resource "aws_vpc" "default-vpc" {
  cidr_block       = "10.0.0.0/16"
  enable_dns_hostnames = true
  tags {
    Name = "kx-as-code-Vpc"
  }
}

output "aws_vpc_id" {
  value = "${aws_vpc.default-vpc.id}"
}

resource "aws_subnet" "private" {
  vpc_id            = aws_vpc.default-vpc.id
  cidr_block        = var.private_subnet_cidr
  availability_zone = var.availability_zones
}


## Security Group##
resource "aws_security_group" "terraform_private_sg" {
  description = "Allow limited inbound external traffic"
  vpc_id      = "${aws_vpc.default-vpc.id}"
  name        = "kx-as-code_sg"

  ingress {
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = 22
    to_port     = 22
  }

  ingress {
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = 8080
    to_port     = 8080
  }

 ingress {
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = 443
    to_port     = 443
  }

  egress {
    protocol    = -1
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = 0
    to_port     = 0
  }

  tags {
    Name = "kx-as-code-sg"
  }
}

output "aws_security_gr_id" {
  value = "${aws_security_group.terraform_private_sg.id}"
}


resource "aws_instance" "web" {
  ami = var.AMI_ID
  instance_type = "t3.large"
  vpc_id = "${aws_vpc.default-vpc.id}"
  private_subnet = var.private_subnet_cidr
  availability_zone = var.availability_zone
  aws_security_group = "${aws_security_group.terraform_private_sg.id}"
  
  tags = {
    Name = "MasterNode"
  }
}
