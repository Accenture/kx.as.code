resource "aws_route53_zone" "demo1_kx_as_code_io" {
  name    = "demo1.kx.as.code.io"
  comment = "Hosted zone for root-level domain"
}

resource "aws_route53_zone" "demo2_kx_as_code_io" {
  name    = "demo2.kx.as.code.io"
  comment = "Hosted zone for root-level domain"
}

resource "aws_route53_zone" "demo3_kx_as_code_io" {
  name    = "demo3.kx.as.code.io"
  comment = "Hosted zone for root-level domain"
}
