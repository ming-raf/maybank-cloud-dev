
# Load Balancer
locals {
  domain_name = "maybank.${var.ENVIRONMENT_NAME}.example.com"
}

resource "aws_route53_zone" "edge" {
  name = local.domain_name
}

resource "aws_lb" "nlb" {
  name               = "${local.name_prefix}-nlb"
  load_balancer_type = "network"
  internal           = false
  subnets            = [
    module.subnets_a.public_subnet_id,
    module.subnets_b.public_subnet_id
  ]
}

resource "aws_lb_target_group" "nlb_tg" {
  name        = "${local.name_prefix}-tg"
  port        = 80
  protocol    = "TCP"
  target_type = "ip"
  vpc_id      = aws_vpc.main.id
}

resource "aws_lb_listener" "nlb_https" {
  load_balancer_arn = aws_lb.nlb.arn
  port              = 443
  protocol          = "TLS"
  ssl_policy        = "ELBSecurityPolicy-TLS13-1-2-2021-06"
  certificate_arn   = aws_acm_certificate.nlb.arn

  depends_on = [aws_acm_certificate_validation.nlb]

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.nlb_tg.arn
  }
}

resource "aws_acm_certificate" "nlb" {
  domain_name       = local.domain_name
  validation_method = "DNS"

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_route53_record" "nlb_cert_validation" {
  for_each = {
    for dvo in aws_acm_certificate.nlb.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      type   = dvo.resource_record_type
      record = dvo.resource_record_value
    }
  }

  zone_id = aws_route53_zone.edge.zone_id
  name    = each.value.name
  type    = each.value.type
  ttl     = 300
  records = [each.value.record]

  allow_overwrite = true
}

resource "aws_acm_certificate_validation" "nlb" {
  certificate_arn         = aws_acm_certificate.nlb.arn
  validation_record_fqdns = [for r in aws_route53_record.nlb_cert_validation : r.value.fqdn]
}

data "aws_elb_hosted_zone_id" "current" {}

resource "aws_route53_record" "nlb_alias" {
  zone_id = aws_route53_zone.edge.zone_id
  name    = local.domain_name
  type    = "A"

  alias {
    name                   = aws_lb.nlb.dns_name
    zone_id                = data.aws_elb_hosted_zone_id.current.id
    evaluate_target_health = false
  }
}
