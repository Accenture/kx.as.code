resource "aws_vpc" "kx-vpc" {
  cidr_block       = var.VPC_CIDR_BLOCK
  enable_dns_hostnames = true
  enable_dns_support = true
}

resource "aws_subnet" "private_one" {
  vpc_id            = aws_vpc.kx-vpc.id
  cidr_block        = var.PRIVATE_ONE_SUBNET_CIDR
  availability_zone = var.AVAILABILITY_ZONE

  tags = {
    Name = "Private Subnet 1"
  }
}

resource "aws_subnet" "private_two" {
  vpc_id            = aws_vpc.kx-vpc.id
  cidr_block        = var.PRIVATE_TWO_SUBNET_CIDR
  availability_zone = var.AVAILABILITY_ZONE

  tags = {
    Name = "Private Subnet 2"
  }
}

resource "aws_subnet" "public" {
  depends_on = [
    aws_vpc.kx-vpc
  ]
  vpc_id = aws_vpc.kx-vpc.id
  cidr_block = var.PUBLIC_SUBNET_CIDR
  availability_zone = "us-east-2c"
  map_public_ip_on_launch = true

  tags = {
    Name = "Public Subnet"
  }
}

resource "aws_internet_gateway" "Internet_Gateway" {
  depends_on = [
    aws_vpc.kx-vpc,
    aws_subnet.private_one,
    aws_subnet.public
  ]

  vpc_id = aws_vpc.kx-vpc.id

  tags = {
    Name = "Internet Gateway"
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
    aws_subnet.private_one,
    aws_subnet.public,
    aws_route_table.Public-Subnet-RT
  ]

  # Public Subnet ID
  subnet_id      = aws_subnet.public.id

  #  Route Table ID
  route_table_id = aws_route_table.Public-Subnet-RT.id
}


resource "aws_eip" "elastic_ip" {
  vpc      = true
}

# NAT gateway
resource "aws_nat_gateway" "nat_gateway" {
  depends_on = [
    aws_subnet.public,
    aws_eip.elastic_ip,
  ]
  allocation_id = aws_eip.elastic_ip.id
  subnet_id     = aws_subnet.public.id

  tags = {
    Name = "NAT Gateway"
  }
}


resource "aws_route_table" "NAT_route_table" {
  depends_on = [
    aws_vpc.kx-vpc,
    aws_nat_gateway.nat_gateway,
  ]

  vpc_id = aws_vpc.kx-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.nat_gateway.id
  }

  tags = {
    Name = "NAT Route Table"
  }
}

# associate route table to private subnet
resource "aws_route_table_association" "associate_routetable_to_private_subnet" {
  depends_on = [
    aws_subnet.private_one,
    aws_route_table.NAT_route_table,
  ]
  subnet_id      = aws_subnet.private_one.id
  route_table_id = aws_route_table.NAT_route_table.id
}

resource aws_security_group vpn_access {
  name = "shared-vpn-access"
  vpc_id = aws_vpc.kx-vpc.id
  ingress {
    from_port = 0
    protocol = "-1"
    to_port = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port = 0
    protocol = "-1"
    to_port = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource aws_ec2_client_vpn_endpoint vpn {
  client_cidr_block = var.VPN_SUBNET_CIDR
  split_tunnel = false
  server_certificate_arn = var.VPN_SERVER_CERT_ARN
  dns_servers = [
    aws_route53_resolver_endpoint.vpn_dns.ip_address.*.ip[0],
    aws_route53_resolver_endpoint.vpn_dns.ip_address.*.ip[1]
  ]
  authentication_options {
    type = "certificate-authentication"
    root_certificate_chain_arn = var.VPN_CLIENT_CERT_ARN
  }
  connection_log_options {
    enabled = false
  }
}

resource aws_ec2_client_vpn_network_association private {
  client_vpn_endpoint_id = aws_ec2_client_vpn_endpoint.vpn.id
  subnet_id              = aws_subnet.private_one.id
}

resource aws_route53_resolver_endpoint vpn_dns {
  name = "vpn-dns-access"
  direction = "INBOUND"
  security_group_ids = [aws_security_group.vpn_dns.id]
  ip_address {
    subnet_id = aws_subnet.private_one.id
  }
  ip_address {
    subnet_id = aws_subnet.private_two.id
  }
}

resource aws_security_group vpn_dns {
  name = "vpn_dns"
  vpc_id = aws_vpc.kx-vpc.id
  ingress {
    from_port = 0
    protocol = "-1"
    to_port = 0
    security_groups = [aws_security_group.vpn_access.id]
  }
  egress {
    from_port = 0
    protocol = "-1"
    to_port = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource null_resource client_vpn_ingress {
  depends_on = [aws_ec2_client_vpn_endpoint.vpn]
  provisioner "local-exec" {
    when    = create
    command = "aws ec2 authorize-client-vpn-ingress --client-vpn-endpoint-id ${aws_ec2_client_vpn_endpoint.vpn.id} --target-network-cidr 0.0.0.0/0 --authorize-all-groups"
  }
  lifecycle {
    create_before_destroy = true
  }
}

resource null_resource client_vpn_route_table {
  depends_on = [aws_ec2_client_vpn_endpoint.vpn]
  provisioner "local-exec" {
    when = create
    command = "aws ec2 create-client-vpn-route --client-vpn-endpoint-id ${aws_ec2_client_vpn_endpoint.vpn.id} --destination-cidr-block 0.0.0.0/0  --target-vpc-subnet-id ${aws_subnet.private_one.id}"
  }
  lifecycle {
    create_before_destroy = true
  }
}

resource null_resource client_vpn_security_group {
  depends_on = [aws_ec2_client_vpn_endpoint.vpn]
  provisioner "local-exec" {
    when = create
    command = "aws ec2 apply-security-groups-to-client-vpn-target-network --client-vpn-endpoint-id ${aws_ec2_client_vpn_endpoint.vpn.id} --vpc-id ${aws_security_group.vpn_access.vpc_id} --security-group-ids ${aws_security_group.vpn_access.id}"
  }
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_security_group" "kx-as-code-main_sg" {
  description = "Allow limited inbound external traffic"
  vpc_id = aws_vpc.kx-vpc.id
  name = "kx-as-code-main_sg"

  ingress {
    description = "SSH"
    protocol = "tcp"
    cidr_blocks = [ aws_subnet.private_one.cidr_block ]
    from_port = 22
    to_port = 22
  }

  ingress {
    description = "NoMachine Remote Desktop"
    protocol = "tcp"
    cidr_blocks = [ aws_subnet.private_one.cidr_block ]
    from_port = 4000
    to_port = 4000
  }

  ingress {
    description = "NoMachine Remote Desktop"
    protocol = "udp"
    cidr_blocks = [ aws_subnet.private_one.cidr_block ]
    from_port = 4000
    to_port = 4000
  }

  egress {
    protocol = -1
    cidr_blocks = ["0.0.0.0/0"]
    from_port = 0
    to_port = 0
  }
}

  resource "aws_security_group_rule" "kx_main_tcp_443" {
    type        = "ingress"
    source_security_group_id = aws_security_group.kx-as-code-worker_sg.id
    security_group_id = aws_security_group.kx-as-code-main_sg.id
    description = "HTTPS"
    protocol = "tcp"
    from_port = 443
    to_port = 443
  }

  resource "aws_security_group_rule" "kx_main_tcp_6443" {
    type        = "ingress"
    source_security_group_id = aws_security_group.kx-as-code-worker_sg.id
    security_group_id = aws_security_group.kx-as-code-main_sg.id
    description = "Kubernetes API server"
    protocol = "tcp"
    from_port = 6443
    to_port = 6443
  }

  resource "aws_security_group_rule" "kx_main_tcp_2379_2380" {
    type        = "ingress"
    source_security_group_id = aws_security_group.kx-as-code-worker_sg.id
    security_group_id = aws_security_group.kx-as-code-main_sg.id
    description = "Kubernetes etcd server client API"
    protocol = "tcp"
    from_port = 2379
    to_port = 2380
  }

  resource "aws_security_group_rule" "kx_main_tcp_10250" {
    type        = "ingress"
    source_security_group_id = aws_security_group.kx-as-code-worker_sg.id
    security_group_id = aws_security_group.kx-as-code-main_sg.id
    description = "kubelet API which allows full node access"
    protocol = "tcp"
    from_port = 10250
    to_port = 10252
  }

  resource "aws_security_group_rule" "kx_main_tcp_9099_9100" {
    type        = "ingress"
    source_security_group_id = aws_security_group.kx-as-code-worker_sg.id
    security_group_id = aws_security_group.kx-as-code-main_sg.id
    description = "Calico Network"
    protocol = "tcp"
    from_port = 9099
    to_port = 9100
  }

  resource "aws_security_group_rule" "kx_main_tcp_179" {
    type        = "ingress"
    source_security_group_id = aws_security_group.kx-as-code-worker_sg.id
    security_group_id = aws_security_group.kx-as-code-main_sg.id
    description = "Calico Network - BGP"
    protocol = "tcp"
    from_port = 179
    to_port = 179
  }

  resource "aws_security_group_rule" "kx_main_tcp_24007_24008" {
    type        = "ingress"
    source_security_group_id = aws_security_group.kx-as-code-worker_sg.id
    security_group_id = aws_security_group.kx-as-code-main_sg.id
    description = "GlusterFS Daemon"
    protocol = "tcp"
    from_port = 24007
    to_port = 24008
  }

  resource "aws_security_group_rule" "kx_main_tcp_38465_38467" {
    type        = "ingress"
    source_security_group_id = aws_security_group.kx-as-code-worker_sg.id
    security_group_id = aws_security_group.kx-as-code-main_sg.id
    description = "GlusterFS Bricks"
    protocol = "tcp"
    from_port = 38465
    to_port = 38467
  }

  resource "aws_security_group_rule" "kx_main_tcp_111" {
    type        = "ingress"
    source_security_group_id = aws_security_group.kx-as-code-worker_sg.id
    security_group_id = aws_security_group.kx-as-code-main_sg.id
    description = "GlusterFS Port Mapper"
    protocol = "tcp"
    from_port = 111
    to_port = 111
  }

  resource "aws_security_group_rule" "kx_main_udp_111" {
    type        = "ingress"
    source_security_group_id = aws_security_group.kx-as-code-worker_sg.id
    security_group_id = aws_security_group.kx-as-code-main_sg.id
    description = "GlusterFS Port Mapper"
    protocol = "udp"
    from_port = 111
    to_port = 111
  }

  resource "aws_security_group_rule" "kx_main_tcp_2049" {
    type        = "ingress"
    source_security_group_id = aws_security_group.kx-as-code-worker_sg.id
    security_group_id = aws_security_group.kx-as-code-main_sg.id
    description = "GlusterFS Port Mapper"
    protocol = "udp"
    from_port = 2049
    to_port = 2049
  }

  resource "aws_security_group_rule" "kx_main_tcp_49152_49155" {
    type        = "ingress"
    source_security_group_id = aws_security_group.kx-as-code-worker_sg.id
    security_group_id = aws_security_group.kx-as-code-main_sg.id
    description = "GlusterFS NFS Server"
    protocol = "tcp"
    from_port = 49152
    to_port = 49155
}

resource "aws_security_group" "kx-as-code-worker_sg" {
  description = "Allow limited inbound traffic from external and worker nodes"
  vpc_id = aws_vpc.kx-vpc.id
  name = "kx-as-code-worker_sg"

  ingress {
    protocol = "tcp"
    cidr_blocks = [ aws_subnet.private_one.cidr_block ]
    from_port = 22
    to_port = 22
  }

  egress {
    protocol    = -1
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = 0
    to_port     = 0
  }
}
  resource "aws_security_group_rule" "kx_worker_tcp_443" {
    type        = "ingress"
    source_security_group_id = aws_security_group.kx-as-code-main_sg.id
    security_group_id = aws_security_group.kx-as-code-worker_sg.id
    protocol    = "tcp"
    from_port   = 443
    to_port     = 443
  }

resource "aws_security_group_rule" "kx_worker_tcp_10250" {
    type        = "ingress"
    source_security_group_id = aws_security_group.kx-as-code-main_sg.id
    security_group_id = aws_security_group.kx-as-code-worker_sg.id
    description = "kubelet API which allows full node access"
    protocol    = "tcp"
    from_port   = 10250
    to_port     = 10250
  }

resource "aws_security_group_rule" "kx_worker_tcp_30000_32767" {
    type        = "ingress"
    source_security_group_id = aws_security_group.kx-as-code-main_sg.id
    security_group_id = aws_security_group.kx-as-code-worker_sg.id
    description = "Kubernetes NodePort Services"
    protocol = "tcp"
    from_port = 30000
    to_port = 32767
  }



resource "aws_route53_zone" "kx-as-code" {
  name = var.KX_DOMAIN

  vpc {
    vpc_id = aws_vpc.kx-vpc.id
  }
}

resource "aws_route53_record" "wildcard" {
  zone_id = aws_route53_zone.kx-as-code.zone_id
  name    = "*.${var.KX_DOMAIN}"
  type    = "CNAME"
  ttl     = 300
  records  = [ "kx-main.${var.KX_DOMAIN}" ]
}
resource "aws_route53_record" "kx-main" {
  zone_id = aws_route53_zone.kx-as-code.zone_id
  name    = "kx-main.${var.KX_DOMAIN}"
  type    = "A"
  ttl     = 300
  records  = [ aws_instance.kx-main.private_ip ]
}

resource "aws_route53_record" "kx-worker" {
  zone_id = aws_route53_zone.kx-as-code.zone_id
  name    = "kx-worker${count.index + 1}.${var.KX_DOMAIN}"
  count   = var.NUM_KX_WORKER_NODES
  type    = "A"
  ttl     = 300
  records = [ element(aws_instance.kx-worker.*.private_ip, count.index) ]
}

