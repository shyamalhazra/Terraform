#...LoadBalancer/variables

variable "alb_sg" {
  type = list
}
variable "public_subnets" {
  type = list
}
variable "log_bucket" {
  type = string
}
variable "alb_name" {
  type = string
}

variable "alb_tg_port" {
  type = number
}
variable "alb_tg_protocol" {
  type = string
}
variable "vpc_id" {
  type = string
}
variable "alb_tg_healthythres" {
  type = number
}
variable "alb_tg_unhealthythres" {
  type = number
}
variable "alb_tg_timeout" {
  type = number
}
variable "alb_tg_interval" {
  type = number
}
variable "alb_listener_port" {
  type = number
}
variable "alb_listenet_protocol" {
  type = string
}