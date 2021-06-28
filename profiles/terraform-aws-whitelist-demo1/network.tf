module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "3.0.0"

  name                   = "${local.prefix}-kx-as-code"
  cidr                   = local.vpc_cidr_block
  azs                    = [local.aws_availability_zone] # data.aws_availability_zones.available.names
  private_subnets        = [local.private_subnet_cidr_one, local.private_subnet_cidr_two]
  public_subnets         = [local.public_subnet_cidr]
  enable_nat_gateway     = true
  single_nat_gateway     = true
  enable_dns_hostnames   = true
  enable_dns_support     = true
  one_nat_gateway_per_az = false

  manage_default_network_acl = true
  default_network_acl_name   = "${local.prefix}-kx-as-code"

}

module "alb" {
  source  = "terraform-aws-modules/alb/aws"
  version = "~> 6.0"

  name = "kx-alb"

  load_balancer_type = "network"

  vpc_id  = module.vpc.vpc_id
  subnets = [module.vpc.public_subnets.0]

  target_groups = [
    {
      name_prefix      = "${local.prefix}"
      backend_protocol = "TCP"
      backend_port     = 80
      target_type      = "instance"
      targets = [
        {
          target_id = aws_instance.kx_main.id
          port      = 80
        }
      ]
    },
    {
      name_prefix      = "${local.prefix}"
      backend_protocol = "TCP"
      backend_port     = 443
      target_type      = "instance"
      targets = [
        {
          target_id = aws_instance.kx_main.id
          port      = 443
        }
      ]
    },
    {
      name_prefix      = "${local.prefix}"
      backend_protocol = "TCP_UDP"
      backend_port     = 4000
      target_type      = "instance"
      targets = [
        {
          target_id = aws_instance.kx_main.id
          port      = 4000
        }
      ]
    }
  ]

  http_tcp_listeners = [
    {
      port               = 80
      protocol           = "TCP"
      target_group_index = 0
    },
    {
      port               = 443
      protocol           = "TCP"
      target_group_index = 1
    },
    {
      port               = 4000
      protocol           = "TCP_UDP"
      target_group_index = 2
    }
  ]

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

resource "aws_route53_record" "wildcard" {
  zone_id = aws_route53_zone.kx_as_code.zone_id
  name    = "*.${local.prefix}.${local.kx_as_code_domain}"
  type    = "CNAME"
  ttl     = 300
  records = [module.alb.lb_dns_name]
}