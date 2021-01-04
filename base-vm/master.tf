variable "ACCESS_KEY" {}
variable "SECRET_KEY" {}
variable "AMI_ID" {}
variable "REGION"

provider "aws" {
  access_key = var.ACCESS_KEY
  secret_key = var.SECRET_KEY
  region = var.REGION
}

resource "aws_instance" "web" {
  ami = var.AMI_ID
  instance_type = "t3.large"
  
  tags = {
    Name = "MasterNode"
  }
}
