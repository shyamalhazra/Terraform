#...LoadBalancer/main..

resource "aws_lb" "shy_alb" {
  name = var.alb_name
  subnets = var.public_subnets
  security_groups = var.alb_sg
  load_balancer_type = "application"
  internal = false
  ip_address_type = "ipv4"
  access_logs {
    bucket = var.log_bucket
    enabled = true
    prefix = "alb"
  }
  lifecycle {
    ignore_changes = [name]
  }
  tags = {
    Name = "Shy_Application_Load_Balancer"
  }
}

resource "aws_lb_target_group" "shy-alb-tg" {
  name = "shy-alb-tg-${substr(uuid(),0 ,3 )}"
  port = var.alb_tg_port #80
  protocol = var.alb_tg_protocol #"HTTP"
  vpc_id = var.vpc_id
  target_type = "instance"
  health_check {
    healthy_threshold = var.alb_tg_healthythres # 2
    unhealthy_threshold = var.alb_tg_unhealthythres
    timeout = var.alb_tg_timeout
    interval = var.alb_tg_interval
  }
  lifecycle {
    ignore_changes = [name]
  }
  tags = {
    Name = "shy-alb-tg-instace"
  }
}

resource "aws_lb_listener" "shy_alb_listener" {
  load_balancer_arn = aws_lb.shy_alb.arn
  port = var.alb_listener_port
  protocol = var.alb_listenet_protocol
  default_action {
    type = "forward"
    target_group_arn = aws_lb_target_group.shy-alb-tg.arn
  }
}