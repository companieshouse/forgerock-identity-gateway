data "aws_acm_certificate" "certificate" {
  count       = var.create_certificate ? 0 : 1
  domain      = var.certificate_domain
  most_recent = true
}

data "aws_route53_zone" "domain" {
  count = var.create_route53_record ? 1 : 0
  name  = var.route53_zone
}

resource "aws_acm_certificate" "certificate" {
  count             = var.create_certificate ? 1 : 0
  domain_name       = var.domain_name
  validation_method = "DNS"

  tags = var.tags
}

resource "aws_route53_record" "certificate_validation" {
  count   = var.create_certificate ? 1 : 0
  name    = element(aws_acm_certificate.certificate.0.domain_validation_options.*.resource_record_name, 0)
  type    = element(aws_acm_certificate.certificate.0.domain_validation_options.*.resource_record_type, 0)
  zone_id = data.aws_route53_zone.domain.0.id
  records = [element(aws_acm_certificate.certificate.0.domain_validation_options.*.resource_record_value, 0)]
  ttl     = 60
}

resource "aws_acm_certificate_validation" "certificate" {
  count                   = var.create_certificate ? 1 : 0
  certificate_arn         = aws_acm_certificate.certificate.0.arn
  validation_record_fqdns = [aws_route53_record.certificate_validation.0.fqdn]
}

resource "aws_route53_record" "lb" {
  count   = var.create_route53_record ? 1 : 0
  name    = var.domain_name
  zone_id = data.aws_route53_zone.domain.0.id
  type    = "A"
  alias {
    name                   = aws_lb.main.dns_name
    zone_id                = aws_lb.main.zone_id
    evaluate_target_health = false
  }
}

resource "aws_lb" "main" {
  name                             = var.service_name
  load_balancer_type               = "application"
  enable_cross_zone_load_balancing = "true"
  internal                         = var.internal
  subnets                          = var.subnet_ids
  security_groups                  = [aws_security_group.main.id]
  enable_deletion_protection       = "true"

  access_logs {
    bucket  = var.elb_access_logs_bucket_name
    prefix  = var.elb_access_logs_prefix
    enabled = true
  }

  tags = var.tags
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.main.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type = "redirect"

    redirect {
      port        = 443
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}

resource "aws_lb_listener" "https" {
  load_balancer_arn = aws_lb.main.arn
  port              = 443
  protocol          = "HTTPS"
  ssl_policy        = var.alb_ssl_policy
  certificate_arn   = var.create_certificate ? aws_acm_certificate_validation.certificate.0.certificate_arn : data.aws_acm_certificate.certificate.0.arn

  default_action {
    target_group_arn = aws_lb_target_group.main.arn
    type             = "forward"
  }
}

resource "aws_lb_target_group" "main" {
  name        = var.service_name
  port        = var.target_port
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "ip"

  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 3
    path                = "/healthcheck"
    interval            = 60
  }

  stickiness {
    enabled     = true
    type        = "app_cookie"
    cookie_name = "IG_SESSIONID"
  }

  tags = var.tags
}

# Old security group - to be deleted
resource "aws_security_group" "lb" {
  description = "Restricts access to the load balancer"
  name        = "${var.service_name}-lb"
  vpc_id      = var.vpc_id

  lifecycle {
    create_before_destroy = true
  }

  tags = var.tags
}

resource "aws_security_group" "main" {
  description = "Restricts access to the load balancer"
  name        = "${var.service_name}-lb-sg"
  vpc_id      = var.vpc_id

  lifecycle {
    create_before_destroy = true
  }

  tags = var.tags
}

resource "aws_vpc_security_group_egress_rule" "all" {
  description = "Allow outbound traffic"

  security_group_id = aws_security_group.main.id

  ip_protocol = "-1"
  cidr_ipv4   = "0.0.0.0/0"
}

resource "aws_vpc_security_group_ingress_rule" "all_80" {
  for_each = toset(var.ingress_cidr_blocks)

  security_group_id = aws_security_group.main.id

  cidr_ipv4   = each.value
  from_port   = 80
  to_port     = 80
  ip_protocol = "tcp"
}

resource "aws_vpc_security_group_ingress_rule" "all_443" {
  for_each = toset(var.ingress_cidr_blocks)

  security_group_id = aws_security_group.main.id

  cidr_ipv4   = each.value
  from_port   = 443
  to_port     = 443
  ip_protocol = "tcp"
}
