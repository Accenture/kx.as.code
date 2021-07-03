resource "tls_private_key" "kx_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "kx_ssh_key" {
  key_name   = "kx-key"
  public_key = tls_private_key.kx_key.public_key_openssh
}

resource "local_file" "kx_ssh_key" {
  content         = tls_private_key.kx_key.private_key_pem
  filename        = "ssh_key"
  file_permission = 400
}

data "aws_ami" "amazon_linux_2" {
  most_recent = true
  owners      = ["amazon"]
  filter {
    name   = "name"
    values = ["amzn2-ami-hvm*"]
  }
}

resource "aws_security_group" "kx_bastion" {
  name        = "kx_bastion"
  description = "Allow SSH and ICMP traffic for bastion"
  vpc_id      = module.vpc.vpc_id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = module.vpc.private_subnets_cidr_blocks
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = local.remote_access_cidrs
  }

  ingress {
    from_port   = 0
    to_port     = -1
    protocol    = "icmp"
    cidr_blocks = module.vpc.private_subnets_cidr_blocks
  }

  ingress {
    from_port   = 8
    to_port     = -1
    protocol    = "icmp"
    cidr_blocks = local.remote_access_cidrs
  }

  egress {
    from_port   = 8
    to_port     = -1
    protocol    = "icmp"
    cidr_blocks = module.vpc.private_subnets_cidr_blocks
  }

  egress {
    from_port   = 0
    to_port     = 8
    protocol    = "icmp"
    cidr_blocks = local.remote_access_cidrs
  }

  egress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = module.vpc.private_subnets_cidr_blocks
  }

  egress {
    from_port   = 32768
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = module.vpc.private_subnets_cidr_blocks
  }

  tags = {
    Name = "kx_bastion"
  }
}

resource "aws_instance" "kx_bastion" {
  ami                    = data.aws_ami.amazon_linux_2.id
  key_name               = aws_key_pair.kx_ssh_key.key_name
  instance_type          = local.bastion_node_instance_type
  vpc_security_group_ids = [module.vpc.default_security_group_id, aws_security_group.kx_bastion.id]
  subnet_id              = module.vpc.public_subnets[0] # aws_subnet.public.id
  source_dest_check      = false
  availability_zone      = local.aws_availability_zone_one

  tags = {
    Name     = "KX.AS.CODE Bastion"
    Hostname = "kx-bastion.${local.kx_as_code_domain}"
  }
}

resource "aws_security_group" "kx_main_nodes" {
  name        = "kx_main"
  description = "Allow SSH and ICMP traffic for kx main"
  vpc_id      = module.vpc.vpc_id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = local.remote_access_cidrs
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = local.remote_access_cidrs
  }

  ingress {
    from_port = 4000
    to_port = 4000
    protocol = "tcp"
    cidr_blocks = local.remote_access_cidrs
  }

  ingress {
    from_port   = 4000
    to_port     = 4000
    protocol    = "udp"
    cidr_blocks = local.remote_access_cidrs
  }

  ingress {
    from_port   = 8
    to_port     = -1
    protocol    = "icmp"
    cidr_blocks = local.remote_access_cidrs
  }

  ingress {
    from_port   = 4003
    to_port     = 65535
    protocol    = "tcp"
    security_groups = [aws_security_group.kx_workers_nodes.id]
  }

  ingress {
    from_port   = 2382
    to_port     = 4000
    protocol    = "tcp"
    security_groups = [aws_security_group.kx_workers_nodes.id]
  }

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    self = true
  }

  ingress {
    from_port   = 1
    to_port     = 65535
    protocol    = "UDP"
    security_groups = [aws_security_group.kx_workers_nodes.id]
  }

  ingress {
    from_port   = 1
    to_port     = 2379
    protocol    = "TCP"
    security_groups = [aws_security_group.kx_workers_nodes.id]
  }

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "4"
    security_groups = [aws_security_group.kx_workers_nodes.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    self = true
  }

  tags = {
    Name = "kx_main"
  }
}

resource "aws_instance" "kx_main" {
  depends_on = [
    module.vpc
  ]
  ami                    = local.main_node_ami_id
  key_name               = aws_key_pair.kx_ssh_key.key_name
  instance_type          = local.main_node_instance_type
  availability_zone      = local.aws_availability_zone_one

  network_interface {
    device_index         = 0
    network_interface_id = aws_network_interface.kx_main.id
  }

  ebs_block_device {
    device_name = "/dev/xvdb"
    volume_type = "gp2"
    volume_size = local.local_storage_volume_size
  }

  ebs_block_device {
    device_name = "/dev/xvdc"
    volume_type = "gp2"
    volume_size = local.glusterfs_storage_volume_size
  }

  tags = {
    Name     = "KX.AS.CODE Main"
    Hostname = "kx-main.${local.kx_as_code_domain}"
  }
}

resource "aws_security_group" "kx_workers_nodes" {
  name = "kx_worker_nodes"
  description = "Allow all traffic between KX-Main and KX-Worker nodes"
  vpc_id = module.vpc.vpc_id

  ingress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    self = true
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    self = true
  }

  tags = {
    Name = "kx_worker"
  }
}

resource "aws_security_group_rule" "kx_worker_kx_main" {
  type      = "ingress"
  from_port = 0
  to_port = 0
  protocol = "-1"
  source_security_group_id = aws_security_group.kx_main_nodes.id
  security_group_id = aws_security_group.kx_workers_nodes.id
}

resource "aws_instance" "kx_worker" {
  depends_on = [
    module.vpc
  ]
  count                  = local.worker_node_count
  ami                    = local.worker_node_ami_id
  key_name               = aws_key_pair.kx_ssh_key.key_name
  instance_type          = local.worker_node_instance_type
  vpc_security_group_ids = [module.vpc.default_security_group_id, aws_security_group.kx_workers_nodes.id]
  subnet_id              = module.vpc.private_subnets[0] # aws_subnet.private_one.id
  source_dest_check      = false
  availability_zone      = local.aws_availability_zone_one

  ebs_block_device {
    device_name = "/dev/xvdb"
    volume_type = "gp2"
    volume_size = local.local_storage_volume_size
  }

  tags = {
    Name     = "KX.AS.CODE Worker ${count.index + 1}"
    Hostname = "kx-worker${count.index + 1}.${local.kx_as_code_domain}"
  }
}
