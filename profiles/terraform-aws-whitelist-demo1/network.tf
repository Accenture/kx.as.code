resource "aws_network_interface" "kx_main" {
  subnet_id       = module.vpc.private_subnets[0]
  security_groups = [module.vpc.default_security_group_id, aws_security_group.kx_main_nodes.id]
  source_dest_check      = false
}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "3.0.0"

  name                   = "${local.prefix}-kx-as-code"
  cidr                   = local.vpc_cidr_block
  azs                    = [local.aws_availability_zone_one,local.aws_availability_zone_two]
  private_subnets        = [local.private_subnet_cidr_one, local.private_subnet_cidr_two]
  public_subnets         = [local.public_subnet_cidr_one,local.public_subnet_cidr_two]
  enable_nat_gateway     = true
  single_nat_gateway     = true
  enable_dns_hostnames   = true
  enable_dhcp_options    = true
  one_nat_gateway_per_az = false

  enable_dns_support     = true
  dhcp_options_domain_name_servers = [ aws_network_interface.kx_main.private_ip, "AmazonProvidedDNS", "8.8.8.8" ]

  manage_default_network_acl = true
  default_network_acl_name   = "${local.prefix}-kx-as-code"

}

resource "aws_vpc_dhcp_options" "dns_resolver" {
  domain_name_servers = ["8.8.8.8", "8.8.4.4"]
}

module "aws_logs" {
  source            = "trussworks/logs/aws"
  s3_bucket_name    = "kx-lb-logs-bucket"
  default_allow     = false
  allow_alb         = true
  allow_nlb         = true
  alb_logs_prefixes = [
    "alb"
  ]
  nlb_logs_prefixes = [
    "nlb"
  ]
}

resource "aws_lb" "kx_network_nlb" {
  name               = "kx-network-nlb"
  internal           = false
  load_balancer_type = "network"
  subnets            = [module.vpc.public_subnets.0,module.vpc.public_subnets.1]

  enable_deletion_protection = false

  access_logs {
    bucket  = module.aws_logs.aws_logs_bucket
    prefix  = "nlb"
    enabled = true
  }

  tags = {
    Environment = "${local.prefix}-kx-as-code"
  }
}

resource "aws_lb_target_group" "http" {
  name     = "http"
  port     = 80
  protocol = "TCP"
  vpc_id   = module.vpc.vpc_id
  target_type = "instance"

  health_check {
    port     = 80
    protocol = "TCP"
  }
}

resource "aws_lb_target_group_attachment" "http" {
  target_group_arn = aws_lb_target_group.http.arn
  target_id = aws_instance.kx_main.id
}

resource "aws_lb_target_group" "https" {
  name     = "https"
  port     = 443
  protocol = "TCP"
  vpc_id   = module.vpc.vpc_id
  target_type = "instance"

  health_check {
    port     = 443
    protocol = "TCP"
  }
}

resource "aws_lb_target_group_attachment" "https" {
  target_group_arn = aws_lb_target_group.https.arn
  target_id = aws_instance.kx_main.id
}

resource "aws_lb_target_group" "rdp" {
  name     = "rdp-tcp"
  port     = 4000
  protocol = "TCP_UDP"
  vpc_id   = module.vpc.vpc_id
  target_type = "instance"

  health_check {
    port     = 4000
    protocol = "TCP"
  }
}

resource "aws_lb_target_group_attachment" "rdp" {
  target_group_arn = aws_lb_target_group.rdp.arn
  target_id = aws_instance.kx_main.id
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.kx_network_nlb.arn
  port              = "80"
  protocol          = "TCP"

  default_action {
    type = "forward"
    target_group_arn = aws_lb_target_group.http.arn
  }
}

resource "aws_lb_listener" "https" {
  load_balancer_arn = aws_lb.kx_network_nlb.arn
  port              = "443"
  protocol          = "TCP"

  default_action {
    type = "forward"
    target_group_arn = aws_lb_target_group.https.arn
  }
}

resource "aws_lb_listener" "rdp" {
  load_balancer_arn = aws_lb.kx_network_nlb.arn
  port              = "4000"
  protocol          = "TCP_UDP"

  default_action {
    type = "forward"
    target_group_arn = aws_lb_target_group.rdp.arn
  }
}

resource "aws_route53_zone" "kx_as_code" {
  name = "${local.prefix}.${local.kx_as_code_domain}"
}

resource "aws_route53_record" "kx_bastion" {
  zone_id = aws_route53_zone.kx_as_code.zone_id
  name    = "kx-bastion.${local.prefix}.${local.kx_as_code_domain}"
  type    = "A"
  ttl     = 300
  records = [aws_instance.kx_bastion.public_ip]
}

resource "aws_route53_record" "kx_main" {
  zone_id = aws_route53_zone.kx_as_code.zone_id
  name    = "kx-main.${local.prefix}.${local.kx_as_code_domain}"
  type    = "A"
  ttl     = 300
  records = [aws_instance.kx_main.private_ip]
}

resource "aws_route53_record" "kx_worker" {
  zone_id = aws_route53_zone.kx_as_code.zone_id
  name    = "kx-worker${count.index + 1}.${local.prefix}.${local.kx_as_code_domain}"
  count   = local.worker_node_count
  type    = "A"
  ttl     = 300
  records = [element(aws_instance.kx_worker.*.private_ip, count.index)]
}

resource "aws_route53_record" "rdp" {
  zone_id = aws_route53_zone.kx_as_code.zone_id
  name    = "rdp.${local.prefix}.${local.kx_as_code_domain}"
  type    = "CNAME"
  ttl     = 300
  records = [aws_lb.kx_network_nlb.dns_name]
}

resource "aws_route53_record" "wildcard" {
  zone_id = aws_route53_zone.kx_as_code.zone_id
  name    = "*.${local.prefix}.${local.kx_as_code_domain}"
  type    = "CNAME"
  ttl     = 300
  records = [aws_lb.kx_network_nlb.dns_name]
}