resource "tls_private_key" "kx_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "kx_ssh_key" {
  key_name   = "kx-key-${local.prefix}"
  public_key = tls_private_key.kx_key.public_key_openssh
}

resource "local_file" "kx_ssh_key" {
  content         = tls_private_key.kx_key.private_key_pem
  filename        = "ssh_key"
  file_permission = 400
}

resource "aws_security_group" "kx_nodes" {
  name        = "kx_main_sg_${local.prefix}"
  description = "Allow SSH and ICMP traffic for kx main"
  vpc_id      = local.vpc_id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = local.remote_access_cidrs_admins
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
    cidr_blocks = local.remote_access_cidrs_admins
  }

  ingress {
    from_port   = 6443
    to_port     = 6443
    protocol    = "tcp"
    cidr_blocks = local.remote_access_cidrs_admins
  }

  ingress {
    from_port   = 4000
    to_port     = 4000
    protocol    = "tcp"
    cidr_blocks = local.remote_access_cidrs_admins
  }

  ingress {
    from_port   = 4000
    to_port     = 4000
    protocol    = "udp"
    cidr_blocks = local.remote_access_cidrs_admins
  }

  ingress {
    from_port   = 8043
    to_port     = 8043
    protocol    = "tcp"
    cidr_blocks = local.remote_access_cidrs_admins
  }

  ingress {
    from_port   = 8
    to_port     = -1
    protocol    = "icmp"
    cidr_blocks = local.remote_access_cidrs_admins
  }

  ingress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"
    self      = true
  }

  egress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"
    self      = true
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "kx_main"
    Environment = "DEV"
    EnvironmentPrefix = local.prefix
    Owner = "${local.owner_surname}, ${local.owner_firstname} <${local.userid}>"
  }
}

resource "aws_instance" "kx_main_admin" {

  depends_on = [
    aws_security_group.kx_nodes,
    aws_key_pair.kx_ssh_key
  ]

  ami               = local.kx_main_ami_id
  key_name          = aws_key_pair.kx_ssh_key.key_name
  instance_type     = local.admin_main_node_instance_type
  iam_instance_profile   = "Ec2ssm"
  vpc_security_group_ids = [ aws_security_group.kx_nodes.id ]
  source_dest_check = false
  availability_zone = local.aws_availability_zone_one

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
    Name     = "KX.AS.CODE Main Admin 1 (${local.prefix}"
    Hostname = "kx-main1.${local.kx_as_code_domain}"
    Environment = "DEV"
    EnvironmentPrefix = local.prefix
    Owner = "${local.owner_surname}, ${local.owner_firstname} <${local.userid}>"
  }

}

resource "aws_instance" "kx_main_replica" {

  count                  = (local.main_node_count - 1) < 0 ? 0 : local.main_node_count - 1
  ami                    = local.kx_node_ami_id
  key_name               = aws_key_pair.kx_ssh_key.key_name
  instance_type          = local.replica_main_node_instance_type
  iam_instance_profile   = "Ec2ssm"
  vpc_security_group_ids = [aws_security_group.kx_nodes.id]
  subnet_id              = local.subnet_id
  source_dest_check      = false
  availability_zone      = local.aws_availability_zone_two

  ebs_block_device {
    device_name = "/dev/xvdb"
    volume_type = "gp2"
    volume_size = local.local_storage_volume_size
  }

  tags = {
    Name     = "KX.AS.CODE Main Additional ${count.index + 2} (${local.prefix}"
    Hostname = "kx-main${count.index + 2}.${local.kx_as_code_domain}"
    Environment = "DEV"
    EnvironmentPrefix = local.prefix
    Owner = "${local.owner_surname}, ${local.owner_firstname} <${local.userid}>"
  }
}

resource "aws_instance" "kx_worker" {
  count                  = local.worker_node_count
  ami                    = local.kx_node_ami_id
  key_name               = aws_key_pair.kx_ssh_key.key_name
  instance_type          = local.worker_node_instance_type
  iam_instance_profile   = "Ec2ssm"
  vpc_security_group_ids = [aws_security_group.kx_nodes.id]
  subnet_id              = local.subnet_id
  source_dest_check      = false
  availability_zone      = local.aws_availability_zone_one

  ebs_block_device {
    device_name = "/dev/xvdb"
    volume_type = "gp2"
    volume_size = local.local_storage_volume_size
  }

  tags = {
    Name     = "KX.AS.CODE Worker ${count.index + 1} (${local.prefix})"
    Hostname = "kx-worker${count.index + 1}.${local.kx_as_code_domain}"
    Environment = "DEV"
    EnvironmentPrefix = local.prefix
    Owner = "${local.owner_surname}, ${local.owner_firstname} <${local.userid}>"
  }
}


