resource "aws_network_interface" "kx_main_admin" {
  subnet_id         = module.vpc.private_subnets[0]
  security_groups   = [module.vpc.default_security_group_id, aws_security_group.kx_main_nodes.id]
  source_dest_check = false
}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "3.0.0"

  name                   = "${local.prefix}-kx-as-code"
  cidr                   = local.vpc_cidr_block
  azs                    = [local.aws_availability_zone_one, local.aws_availability_zone_two]
  private_subnets        = [local.private_subnet_cidr_one, local.private_subnet_cidr_two]
  public_subnets         = [local.public_subnet_cidr_one, local.public_subnet_cidr_two]
  enable_nat_gateway     = true
  single_nat_gateway     = true
  enable_dns_hostnames   = true
  enable_dhcp_options    = true
  one_nat_gateway_per_az = false

  enable_dns_support               = true
  dhcp_options_domain_name_servers = [aws_network_interface.kx_main_admin.private_ip, "AmazonProvidedDNS", "8.8.8.8"]

  manage_default_network_acl = true
  default_network_acl_name   = "${local.prefix}-kx-as-code"

}

resource "aws_vpc_dhcp_options" "dns_resolver" {
  domain_name_servers = ["8.8.8.8", "8.8.4.4"]
}

#module "aws_logs" {
#  source            = "trussworks/logs/aws"
#  s3_bucket_name    = "kx-lb-logs-bucket"
#  default_allow     = false
#  allow_alb         = true
#  allow_nlb         = true
#  alb_logs_prefixes = [
#    "alb"
#  ]
#  nlb_logs_prefixes = [
#    "nlb"
#  ]
#}

resource "aws_lb" "kx_network_external_nlb" {
  name               = "kx-network-external-nlb"
  internal           = false
  load_balancer_type = "network"
  subnets            = local.lb_public_subnets

  enable_deletion_protection = false

  #access_logs {
  #  bucket  = module.aws_logs.aws_logs_bucket
  #  prefix  = "nlb"
  #  enabled = true
  #}

  tags = {
    Environment = "${local.prefix}-kx-as-code"
  }
}

resource "aws_lb_target_group" "http" {
  name        = "http"
  port        = 80
  protocol    = "TCP"
  vpc_id      = module.vpc.vpc_id
  target_type = "instance"

  health_check {
    port     = 80
    protocol = "TCP"
  }
}

resource "aws_lb_target_group_attachment" "http" {
  target_group_arn = aws_lb_target_group.http.arn
  target_id        = aws_instance.kx_main_admin.id
}

resource "aws_alb_target_group_attachment" "http_replica" {
  count            = length(aws_instance.kx_main_replica)
  target_group_arn = aws_lb_target_group.http.arn
  target_id        = aws_instance.kx_main_replica[count.index].id
}

resource "aws_lb_target_group" "api_external" {
  name        = "api-external"
  port        = 6443
  protocol    = "TCP"
  vpc_id      = module.vpc.vpc_id
  target_type = "instance"

  health_check {
    port     = 6443
    protocol = "TCP"
  }
}

resource "aws_lb_target_group_attachment" "api_external" {
  target_group_arn = aws_lb_target_group.api_external.arn
  target_id        = aws_instance.kx_main_admin.id
}

resource "aws_lb_target_group_attachment" "api_external_replica" {
  count            = length(aws_instance.kx_main_replica)
  target_group_arn = aws_lb_target_group.api_external.arn
  target_id        = aws_instance.kx_main_replica[count.index].id
}

resource "aws_lb_target_group" "https" {
  name        = "https"
  port        = 443
  protocol    = "TCP"
  vpc_id      = module.vpc.vpc_id
  target_type = "instance"

  health_check {
    port     = 443
    protocol = "TCP"
  }
}

resource "aws_lb_target_group_attachment" "https" {
  target_group_arn = aws_lb_target_group.https.arn
  target_id        = aws_instance.kx_main_admin.id
}

resource "aws_lb_target_group_attachment" "https_replica" {
  count            = length(aws_instance.kx_main_replica)
  target_group_arn = aws_lb_target_group.https.arn
  target_id        = aws_instance.kx_main_replica[count.index].id
}

resource "aws_lb_target_group" "rdp" {
  name        = "rdp-tcp"
  port        = 4000
  protocol    = "TCP_UDP"
  vpc_id      = module.vpc.vpc_id
  target_type = "instance"

  health_check {
    port     = 4000
    protocol = "TCP"
  }
}

resource "aws_lb_target_group_attachment" "rdp" {
  target_group_arn = aws_lb_target_group.rdp.arn
  target_id        = aws_instance.kx_main_admin.id
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.kx_network_external_nlb.arn
  port              = "80"
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.http.arn
  }
}

resource "aws_lb_listener" "https" {
  load_balancer_arn = aws_lb.kx_network_external_nlb.arn
  port              = "443"
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.https.arn
  }
}

resource "aws_lb_listener" "api_external" {
  load_balancer_arn = aws_lb.kx_network_external_nlb.arn
  port              = "6443"
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.api_external.arn
  }
}

resource "aws_lb_listener" "rdp" {
  load_balancer_arn = aws_lb.kx_network_external_nlb.arn
  port              = "4000"
  protocol          = "TCP_UDP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.rdp.arn
  }
}

data "aws_route53_zone" "kx_as_code" {
  name = "${local.prefix}.${local.kx_as_code_domain}"
}

resource "aws_route53_record" "kx_bastion" {
  zone_id = data.aws_route53_zone.kx_as_code.zone_id
  name    = "kx-bastion.${local.prefix}.${local.kx_as_code_domain}"
  type    = "A"
  ttl     = 300
  records = [aws_instance.kx_bastion.public_ip]
}

resource "aws_route53_record" "kx_main_admin" {
  zone_id = data.aws_route53_zone.kx_as_code.zone_id
  name    = "kx-main1.${local.prefix}.${local.kx_as_code_domain}"
  type    = "A"
  ttl     = 300
  records = [aws_instance.kx_main_admin.private_ip]
}

resource "aws_route53_record" "kx_main_replica" {
  zone_id = data.aws_route53_zone.kx_as_code.zone_id
  name    = "kx-main${count.index + 2}.${local.prefix}.${local.kx_as_code_domain}"
  count   = local.main_node_count - 1
  type    = "A"
  ttl     = 300
  records = [element(aws_instance.kx_main_replica.*.private_ip, count.index)]
}

resource "aws_route53_record" "kx_caa" {
  zone_id = data.aws_route53_zone.kx_as_code.zone_id
  name    = "${local.prefix}.${local.kx_as_code_domain}"
  type    = "CAA"
  ttl     = 300
  records = ["0 issue \"letsencrypt.org\""]
}

resource "aws_route53_record" "kx_mx" {
  zone_id = data.aws_route53_zone.kx_as_code.zone_id
  name    = "${local.prefix}.${local.kx_as_code_domain}"
  type    = "MX"
  ttl     = 300
  records = ["10 ${local.mx_dns_record}"]
}

resource "aws_route53_record" "kx_worker" {
  zone_id = data.aws_route53_zone.kx_as_code.zone_id
  name    = "kx-worker${count.index + 1}.${local.prefix}.${local.kx_as_code_domain}"
  count   = local.worker_node_count
  type    = "A"
  ttl     = 300
  records = [element(aws_instance.kx_worker.*.private_ip, count.index)]
}

resource "aws_route53_record" "rdp" {
  zone_id = data.aws_route53_zone.kx_as_code.zone_id
  name    = "rdp.${local.prefix}.${local.kx_as_code_domain}"
  type    = "CNAME"
  ttl     = 300
  records = [aws_lb.kx_network_external_nlb.dns_name]
}

resource "aws_route53_health_check" "api_internal" {
  fqdn              = "api-internal.${local.prefix}.${local.kx_as_code_domain}"
  port              = 6443
  type              = "TCP"
  failure_threshold = "5"
  request_interval  = "30"
}

resource "aws_route53_record" "k8s_api_internal_admin" {
  zone_id                          = data.aws_route53_zone.kx_as_code.zone_id
  name                             = "api-internal.${local.prefix}.${local.kx_as_code_domain}"
  type                             = "A"
  ttl                              = 300
  health_check_id                  = aws_route53_health_check.api_internal.id
  multivalue_answer_routing_policy = true
  set_identifier                   = "1"
  records = [
    aws_instance.kx_main_admin.private_ip
  ]
}

resource "aws_route53_record" "k8s_api_internal_replica" {
  count                            = (local.main_node_count - 1) < 0 ? 0 : local.main_node_count - 1
  zone_id                          = data.aws_route53_zone.kx_as_code.zone_id
  name                             = "api-internal.${local.prefix}.${local.kx_as_code_domain}"
  type                             = "A"
  ttl                              = 300
  health_check_id                  = aws_route53_health_check.api_internal.id
  multivalue_answer_routing_policy = true
  set_identifier                   = count.index + 2
  records = [
    aws_instance.kx_main_replica[count.index].private_ip
  ]
}

resource "aws_route53_record" "wildcard" {
  zone_id = data.aws_route53_zone.kx_as_code.zone_id
  name    = "*.${local.prefix}.${local.kx_as_code_domain}"
  type    = "CNAME"
  ttl     = 300
  records = [aws_lb.kx_network_external_nlb.dns_name]
}
