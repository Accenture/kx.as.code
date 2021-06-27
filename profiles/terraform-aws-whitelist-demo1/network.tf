locals {
  network_acls_public_inbound = flatten([for i, cidr in local.remote_access_cidrs : [
    {
      rule_number = "10${i + 20}"
      rule_action = "allow"
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      cidr_block  = cidr
    },
    {
      rule_number = "10${i + 30}"
      rule_action = "allow"
      from_port   = 80
      to_port     = 80
      protocol    = "tcp"
      cidr_block  = cidr
    },
    {
      rule_number = "10${i + 40}"
      rule_action = "allow"
      from_port   = 443
      to_port     = 443
      protocol    = "tcp"
      cidr_block  = cidr
    }]
  ])
  network_acls_public_inbound_default = [
    {
      rule_number = 100
      rule_action = "allow"
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      cidr_block  = module.vpc.private_subnets_cidr_blocks[0]
    },
    {
      rule_number = 101
      rule_action = "allow"
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      cidr_block  = module.vpc.private_subnets_cidr_blocks[1]
    },
    {
      rule_number = 102
      rule_action = "allow"
      from_port   = 80
      to_port     = 80
      protocol    = "tcp"
      cidr_block  = module.vpc.private_subnets_cidr_blocks[0]
    },
    {
      rule_number = 103
      rule_action = "allow"
      from_port   = 80
      to_port     = 80
      protocol    = "tcp"
      cidr_block  = module.vpc.private_subnets_cidr_blocks[1]
    },
    {
      rule_number = 104
      rule_action = "allow"
      from_port   = 443
      to_port     = 443
      protocol    = "tcp"
      cidr_block  = module.vpc.private_subnets_cidr_blocks[0]
    },
    {
      rule_number = 105
      rule_action = "allow"
      from_port   = 443
      to_port     = 443
      protocol    = "tcp"
      cidr_block  = module.vpc.private_subnets_cidr_blocks[1]
    },
    {
      rule_number = 900
      rule_action = "allow"
      from_port   = 1024
      to_port     = 65535
      protocol    = "tcp"
      cidr_block  = module.vpc.private_subnets_cidr_blocks[0]
    },
    {
      rule_number = 901
      rule_action = "allow"
      from_port   = 1024
      to_port     = 65535
      protocol    = "tcp"
      cidr_block  = module.vpc.private_subnets_cidr_blocks[1]
    }
  ]
  network_acls_public_outbound = flatten([for i, cidr in local.remote_access_cidrs : [
    {
      rule_number = "10${i + 10}"
      rule_action = "allow"
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      cidr_block  = cidr
    },
    {
      rule_number = "10${i + 20}"
      rule_action = "allow"
      from_port   = 80
      to_port     = 80
      protocol    = "tcp"
      cidr_block  = cidr
    },
    {
      rule_number = "10${i + 30}"
      rule_action = "allow"
      from_port   = 443
      to_port     = 443
      protocol    = "tcp"
      cidr_block  = cidr
    },
    {
      rule_number = "90${i}"
      rule_action = "allow"
      from_port   = 1024
      to_port     = 65535
      protocol    = "tcp"
      cidr_block  = cidr
    }]
  ])
  network_acls_public_outbound_default = [
    {
      rule_number = 100
      rule_action = "allow"
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      cidr_block  = module.vpc.private_subnets_cidr_blocks[0]
    },
    {
      rule_number = 101
      rule_action = "allow"
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      cidr_block  = module.vpc.private_subnets_cidr_blocks[1]
    },
    {
      rule_number = 102
      rule_action = "allow"
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      cidr_block  = module.vpc.public_subnets_cidr_blocks[0]
    },
    {
      rule_number = 103
      rule_action = "allow"
      from_port   = 80
      to_port     = 80
      protocol    = "tcp"
      cidr_block  = module.vpc.private_subnets_cidr_blocks[0]
    },
    {
      rule_number = 104
      rule_action = "allow"
      from_port   = 80
      to_port     = 80
      protocol    = "tcp"
      cidr_block  = module.vpc.private_subnets_cidr_blocks[1]
    },
    {
      rule_number = 105
      rule_action = "allow"
      from_port   = 80
      to_port     = 80
      protocol    = "tcp"
      cidr_block  = module.vpc.public_subnets_cidr_blocks[0]
    },
    {
      rule_number = 106
      rule_action = "allow"
      from_port   = 443
      to_port     = 443
      protocol    = "tcp"
      cidr_block  = module.vpc.private_subnets_cidr_blocks[0]
    },
    {
      rule_number = 107
      rule_action = "allow"
      from_port   = 443
      to_port     = 443
      protocol    = "tcp"
      cidr_block  = module.vpc.private_subnets_cidr_blocks[1]
    },
    {
      rule_number = 108
      rule_action = "allow"
      from_port   = 443
      to_port     = 443
      protocol    = "tcp"
      cidr_block  = module.vpc.public_subnets_cidr_blocks[0]
    }
  ]
  network_acls_private_inbound = [
    {
      rule_number = 100
      rule_action = "allow"
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      cidr_block  = module.vpc.public_subnets_cidr_blocks[0]
    },
    {
      rule_number = 101
      rule_action = "allow"
      from_port   = 80
      to_port     = 80
      protocol    = "tcp"
      cidr_block  = module.vpc.public_subnets_cidr_blocks[0]
    },
    {
      rule_number = 102
      rule_action = "allow"
      from_port   = 443
      to_port     = 443
      protocol    = "tcp"
      cidr_block  = module.vpc.public_subnets_cidr_blocks[0]
    }
  ]
  network_acls_private_outbound = [
    {
      rule_number = 100
      rule_action = "allow"
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      cidr_block  = module.vpc.public_subnets_cidr_blocks[0]
    },
    {
      rule_number = 101
      rule_action = "allow"
      from_port   = 80
      to_port     = 80
      protocol    = "tcp"
      cidr_block  = module.vpc.public_subnets_cidr_blocks[0]
    },
    {
      rule_number = 102
      rule_action = "allow"
      from_port   = 443
      to_port     = 443
      protocol    = "tcp"
      cidr_block  = module.vpc.public_subnets_cidr_blocks[0]
    },
    {
      rule_number = 900
      rule_action = "allow"
      from_port   = 1024
      to_port     = 65535
      protocol    = "tcp"
      cidr_block  = module.vpc.public_subnets_cidr_blocks[0]
    }
  ]
}

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

  public_dedicated_network_acl = true
  public_inbound_acl_rules     = concat(local.network_acls_public_inbound_default, local.network_acls_public_inbound)
  public_outbound_acl_rules    = concat(local.network_acls_public_outbound_default, local.network_acls_public_outbound)

  private_dedicated_network_acl = true
  private_inbound_acl_rules     = local.network_acls_private_inbound
  private_outbound_acl_rules    = local.network_acls_private_outbound

  manage_default_security_group = true
  default_security_group_name   = "${local.prefix}-kx-as-code"
  default_security_group_ingress = [for cidr in local.remote_access_cidrs :
    {
      type        = "ingress"
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      cidr_blocks = cidr
  }]
  default_security_group_egress = [for cidr in local.remote_access_cidrs :
    {
      type        = "egress"
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      cidr_blocks = cidr
  }]
}

#resource "aws_kms_key" "kx_alb_logs_key" {
#  description             = "This key is used to encrypt bucket objects"
#  deletion_window_in_days = 10
#}

#resource "aws_s3_bucket" "kx_alb_logs" {
#  bucket = "kx-alb-logs"
#  acl    = "private"
#  force_destroy = true

#  server_side_encryption_configuration {
#    rule {
#      apply_server_side_encryption_by_default {
#        kms_master_key_id = aws_kms_key.kx_alb_logs_key.arn
#        sse_algorithm     = "aws:kms"
#      }
#    }
#  }
#}

#data "aws_elb_service_account" "main" {}

#resource "aws_s3_bucket_policy" "lb-bucket-policy" {
#  bucket = "${aws_s3_bucket.kx_alb_logs.id}"
#
#  policy = <<POLICY
#{
#  "Id": "kxPolicy",
#  "Version": "2012-10-17",
#  "Statement": [
#    {
#      "Sid": "kxStmt",
#      "Action": [
#        "s3:PutObject"
#      ],
#      "Effect": "Allow",
#      "Resource": "arn:aws:s3:::kx-alb-logs/http-lb/*",
#      "Principal": {
#        "AWS": [
#           "${data.aws_elb_service_account.main.arn}"
#        ]
#      }
#    }
#  ]
#}
#POLICY
#}

module "alb" {
  source  = "terraform-aws-modules/alb/aws"
  version = "~> 6.0"

  name = "kx-alb"

  load_balancer_type = "network"

  vpc_id  = module.vpc.vpc_id
  subnets = [module.vpc.public_subnets.0]

  #access_logs = {
  #  bucket = "kx-alb-logs"
  #}

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
    }
  ]

}

resource "aws_route53_zone" "kx_as_code" {
  name = "${local.prefix}.${local.kx_as_code_domain}"

  vpc {
    vpc_id = module.vpc.vpc_id
  }
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