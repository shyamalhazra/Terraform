output "alb_id" {
  value = aws_lb.shy_alb.id
}
output "lb_target_group_arn" {
  value = aws_lb_target_group.shy-alb-tg.arn
}