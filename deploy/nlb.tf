
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
  port              = 80
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.nlb_tg.arn
  }
}

data "aws_elb_hosted_zone_id" "current" {}

resource "aws_route53_record" "nlb_alias" {
  zone_id = aws_route53_zone.edge.zone_id
  name    = "nlb.${local.domain_name}"
  type    = "A"

  alias {
    name                   = aws_lb.nlb.dns_name
    zone_id                = data.aws_elb_hosted_zone_id.current.id
    evaluate_target_health = false
  }
}
