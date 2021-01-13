variable "ACCESS_KEY" {}
variable "SECRET_KEY" {}
variable "KX_MAIN_AMI_ID" {}
variable "KX_WORKER_AMI_ID" {}
variable "KX_CA_AMI_ID" {}
variable "KX_VPN_AMI_ID" {}
variable "REGION" {}
variable "PRIVATE_SUBNET_CIDR" {}
variable "AVAILABILITY_ZONE" {}
variable "PUBLIC_KEY" {}

provider "aws" {
  access_key = var.ACCESS_KEY
  secret_key = var.SECRET_KEY
  region = var.REGION
}

resource "tls_private_key" "kx-key" {
  algorithm = "RSA"
}

module "key_pair" {
  source = "terraform-aws-modules/key-pair/aws"
  key_name   = "kx-key"
  public_key = tls_private_key.kx-key.public_key_openssh
}

resource "aws_vpc" "kx-vpc" {
  cidr_block       = "10.0.0.0/16"
  enable_dns_hostnames = true
}

output "aws_vpc_id" {
  value = aws_vpc.kx-vpc.id
}

output "kx-main_instance_ip_addr" {
  value = aws_instance.kx-main.private_ip
}

resource "aws_subnet" "private" {
  vpc_id            = aws_vpc.kx-vpc.id
  cidr_block        = var.PRIVATE_SUBNET_CIDR
  availability_zone = var.AVAILABILITY_ZONE
}

resource "aws_subnet" "public" {
  depends_on = [
    aws_vpc.kx-vpc
  ]
  vpc_id = aws_vpc.kx-vpc.id
  cidr_block = "10.0.3.0/24"
  availability_zone = "us-east-2c"
  map_public_ip_on_launch = true

  tags = {
    Name = "Public Subnet"
  }
}

resource "aws_internet_gateway" "Internet_Gateway" {
  depends_on = [
    aws_vpc.kx-vpc,
    aws_subnet.private,
    aws_subnet.public
  ]

  vpc_id = aws_vpc.kx-vpc.id

  tags = {
    Name = "IG-Public-&-Private-VPC"
  }
}

resource "aws_route_table" "Public-Subnet-RT" {
  depends_on = [
    aws_vpc.kx-vpc,
    aws_internet_gateway.Internet_Gateway
  ]

  # VPC ID
  vpc_id = aws_vpc.kx-vpc.id

  # NAT Rule
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.Internet_Gateway.id
  }

  tags = {
    Name = "Route Table for Internet Gateway"
  }
}

resource "aws_route_table_association" "RT-IG-Association" {

  depends_on = [
    aws_vpc.kx-vpc,
    aws_subnet.private,
    aws_subnet.public,
    aws_route_table.Public-Subnet-RT
  ]

  # Public Subnet ID
  subnet_id      = aws_subnet.public.id

  #  Route Table ID
  route_table_id = aws_route_table.Public-Subnet-RT.id
}



resource "aws_security_group" "kx-as-code_sg" {
  description = "Allow limited inbound external traffic"
  vpc_id      = aws_vpc.kx-vpc.id
  name        = "kx-as-code_sg"

  ingress {
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = 22
    to_port     = 22
    security_groups = [aws_security_group.kx-as-code-vpn_sg.id]
  }

  ingress {
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = 4000
    to_port     = 4000
    security_groups = [aws_security_group.kx-as-code-vpn_sg.id]
  }

  ingress {
    protocol    = "udp"
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = 4000
    to_port     = 4000
    security_groups = [aws_security_group.kx-as-code-vpn_sg.id]
  }

 ingress {
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = 443
    to_port     = 443
   security_groups = [aws_security_group.kx-as-code-vpn_sg.id]
  }

  egress {
    protocol    = -1
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = 0
    to_port     = 0
  }
}

resource "aws_security_group" "kx-as-code-ca_sg" {
  description = "Allow limited inbound external traffic"
  vpc_id      = aws_vpc.kx-vpc.id
  name        = "kx-as-code-ca_sg"

  ingress {
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = 22
    to_port     = 22
    security_groups = [aws_security_group.kx-as-code-vpn_sg.id]
  }

  egress {
    protocol    = -1
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = 0
    to_port     = 0
  }
}

resource "aws_security_group" "kx-as-code-vpn_sg" {

  depends_on = [
    aws_vpc.kx-vpc,
    aws_subnet.private,
    aws_subnet.public
  ]

  description = "Allow limited inbound external traffic"
  vpc_id      = aws_vpc.kx-vpc.id
  name        = "kx-as-code-vpn_sg"

  ingress {
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = 22
    to_port     = 22
  }

  ingress {
    protocol    = "udp"
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = 1194
    to_port     = 1194
  }

  egress {
    protocol    = -1
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = 0
    to_port     = 0
  }
}

output "aws_security_gr_id" {
  value = aws_security_group.kx-as-code_sg.id
}


resource "aws_instance" "kx-main" {
  depends_on = [ aws_security_group.kx-as-code_sg, tls_private_key.kx-key, module.key_pair ]
  ami = var.KX_MAIN_AMI_ID
  key_name = module.key_pair.this_key_pair_key_name
  instance_type = "t3.large"
  vpc_security_group_ids = [ aws_security_group.kx-as-code_sg.id ]
  subnet_id = aws_subnet.private.id
  availability_zone = var.AVAILABILITY_ZONE
  #private_dns = "kx-main"

  tags = {
    Name = "KX.AS.CODE Main"
  }
}

resource "aws_instance" "kx-worker" {
  depends_on = [ aws_instance.kx-main, aws_security_group.kx-as-code_sg, tls_private_key.kx-key, module.key_pair ]
  ami = var.KX_WORKER_AMI_ID
  key_name = module.key_pair.this_key_pair_key_name
  instance_type = "t3.large"
  vpc_security_group_ids = [ aws_security_group.kx-as-code_sg.id ]
  subnet_id = aws_subnet.private.id
  count = 2
  availability_zone = var.AVAILABILITY_ZONE
  #private_dns = "kx-worker${count.index + 1}"

  tags = {
    Name = "KX.AS.CODE Worker"
  }

}

resource "aws_instance" "kx-ca" {
  depends_on = [ aws_security_group.kx-as-code_sg, tls_private_key.kx-key, module.key_pair ]
  ami = var.KX_CA_AMI_ID
  key_name = module.key_pair.this_key_pair_key_name
  instance_type = "t3.small"
  vpc_security_group_ids = [ aws_security_group.kx-as-code-ca_sg.id ]
  subnet_id = aws_subnet.private.id
  availability_zone = var.AVAILABILITY_ZONE
  #private_dns = "kx-worker${count.index + 1}"

  tags = {
    Name = "KX.AS.CODE CA"
  }
}

resource "aws_instance" "kx-vpn" {
  depends_on = [ aws_instance.kx-main, aws_instance.kx-ca, aws_security_group.kx-as-code-vpn_sg, tls_private_key.kx-key, module.key_pair ]
  ami = var.KX_VPN_AMI_ID
  key_name = module.key_pair.this_key_pair_key_name
  instance_type = "t3.small"
  vpc_security_group_ids = [ aws_security_group.kx-as-code-vpn_sg.id ]
  subnet_id = aws_subnet.public.id
  availability_zone = var.AVAILABILITY_ZONE
  #private_dns = "kx-worker${count.index + 1}"

  provisioner "remote-exec" {
    connection {
      type     = "ssh"
      user     = "admin"
      private_key = tls_private_key.kx-key.private_key_pem
      host        = aws_instance.kx-vpn.public_ip
    }
    inline = [
      "echo ${aws_instance.kx-main.private_ip} | tee /var/tmp/kx-main.ip"
    ]
  }

  tags = {
    Name = "KX.AS.CODE VPN"
  }
}