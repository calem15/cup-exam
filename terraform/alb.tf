resource "aws_security_group" "protected_lb_sg" {
  name        = "${var.cup_alb_prefix}-protected-LB"
  description = "Security group for Protected LB"
  vpc_id      = module.main_vpc.vpc_id

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    description = "Allow HTTPS to Trusted IPs"
    cidr_blocks = var.whitelist_ip
  }
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    description = "Allow HTTP to Trusted IPs"
    cidr_blocks = var.whitelist_ip
    }
  egress {
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
        Name = "${var.cup_alb_prefix}-protected-LB"
        }
  }

resource "aws_security_group" "internal_lb_sg" {
  name        = "${var.cup_alb_prefix}-internal-LB"
  description = "Security group for internal tools LB"
  vpc_id      = module.main_vpc.vpc_id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    description = "Allow HTTP to Trusted IPs"
    cidr_blocks = [var.cidr_block]
    }
  egress {
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
        Name = "${var.cup_alb_prefix}-protected-LB"
        }
  }

resource "aws_lb" "cup_alb" {
  name               = "${var.cup_alb_prefix}"
  internal           = true
  enable_deletion_protection = true
  subnets            = module.main_vpc.private_subnets
  load_balancer_type = "application"
  security_groups    = [
    aws_security_group.protected_lb_sg.id,
    aws_security_group.internal_lb_sg.id
    ]
  
  tags = {
        Name = "${var.cup_alb_prefix}-protected-LB"
        }
}

resource "aws_lb_listener_rule" "http_rule" {
  listener_arn = aws_lb_listener.https_fixed_response.arn
  priority     = 100

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.grafana-tg.arn
  }

  condition {
    path_pattern {
      values = ["/*"]
    }
  }
}

resource "aws_lb_target_group" "grafana-tg" {
  name        = "grafana-alb-tg"
  port        = var.grafana_int_port
  protocol    = "HTTP"
  vpc_id      = module.main_vpc.vpc_id
  target_type = "instance"
  stickiness {
    enabled = true
    type    = "lb_cookie"
  }

  health_check {
    healthy_threshold   = "3"
    interval            = "40"
    protocol            = "HTTP"
    port                = var.grafana_int_port
    matcher             = "200-499"
    timeout             = "20"
    path                = "/"
    unhealthy_threshold = "3"
  }
}

resource "aws_lb_target_group_attachment" "grafana" {
  target_group_arn = aws_lb_target_group.grafana-tg.arn
  target_id        = module.ec2_instance_prometheus.id
  port             = 80
}