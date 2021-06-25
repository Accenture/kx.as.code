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
  availability_zone      = local.aws_availability_zone

  tags = {
    Name     = "KX.AS.CODE Bastion"
    Hostname = "kx-bastion.${local.kx_as_code_domain}"
  }
}

resource "aws_security_group" "kx_main" {
  name        = "kx_main"
  description = "Allow SSH and ICMP traffic for kx main"
  vpc_id      = module.vpc.vpc_id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = module.vpc.public_subnets_cidr_blocks
  }

  ingress {
    from_port   = 8
    to_port     = -1
    protocol    = "icmp"
    cidr_blocks = module.vpc.public_subnets_cidr_blocks
  }

  egress {
    from_port   = 0
    to_port     = 8
    protocol    = "icmp"
    cidr_blocks = module.vpc.public_subnets_cidr_blocks
  }

  egress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = module.vpc.public_subnets_cidr_blocks
  }

  egress {
    from_port   = 32768
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = module.vpc.public_subnets_cidr_blocks
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
  vpc_security_group_ids = [module.vpc.default_security_group_id, aws_security_group.kx_main.id]
  subnet_id              = module.vpc.private_subnets[0] # aws_subnet.private_one.id
  source_dest_check      = false
  availability_zone      = local.aws_availability_zone

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


resource "aws_instance" "kx_worker" {
  depends_on = [
    module.vpc
  ]
  count                  = local.worker_node_count
  ami                    = local.main_node_ami_id
  key_name               = aws_key_pair.kx_ssh_key.key_name
  instance_type          = local.main_node_instance_type
  vpc_security_group_ids = [module.vpc.default_security_group_id, aws_security_group.kx_main.id]
  subnet_id              = module.vpc.private_subnets[0] # aws_subnet.private_one.id
  source_dest_check      = false
  availability_zone      = local.aws_availability_zone

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
