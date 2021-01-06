variable "ACCESS_KEY" {}
variable "SECRET_KEY" {}
variable "AMI_ID" {}
variable "REGION" {}

provider "aws" {
  access_key = var.ACCESS_KEY
  secret_key = var.SECRET_KEY
  region = var.REGION
}
/*
#resource "aws_vpc" "terraform-vpc" {
 # cidr_block       = "172.16.0.0/16"
  #enable_dns_hostnames = true
  #tags {
   # Name = "terraform-demo-vpc"
  #}
#}

#output "aws_vpc_id" {
 # value = "${aws_vpc.terraform-vpc.id}"
#}

## Security Group##
#resource "aws_security_group" "terraform_private_sg" {
 # description = "Allow limited inbound external traffic"
  #vpc_id      = "${aws_vpc.terraform-vpc.id}"
  #name        = "terraform_ec2_private_sg"

 # ingress {
  #  protocol    = "tcp"
   # cidr_blocks = ["0.0.0.0/0"]
    #from_port   = 22
   # to_port     = 22
 # }

  #ingress {
   # protocol    = "tcp"
  #  cidr_blocks = ["0.0.0.0/0"]
   # from_port   = 8080
   # to_port     = 8080
  #}

#  ingress {
 #   protocol    = "tcp"
  #  cidr_blocks = ["0.0.0.0/0"]
   # from_port   = 443
    #to_port     = 443
  #}

#  egress {
 #   protocol    = -1
  #  cidr_blocks = ["0.0.0.0/0"]
   # from_port   = 0
    #to_port     = 0
  #}

  #tags {
   # Name = "ec2-private-sg"
  #}
#}

#output "aws_security_gr_id" {
 # value = "${aws_security_group.terraform_private_sg.id}"
#}
*/

resource "aws_instance" "web" {
  ami = var.AMI_ID
  instance_type = "t3.large"
  
  tags = {
    Name = "MasterNode"
  }
}
