#root/main

module "networking" {
  source    = "./Networking"
  vpc_cidr  = "192.168.0.0/20"
  access_ip = var.access_ip
  #public_cidr = ["192.168.1.0/24","192.168.2.0/24"]
  public_cidr = [for i in range(1, 3, 1) : cidrsubnet("192.168.0.0/20", 4, i)]
  #private_cidr = ["192.168.3.0/24","192.168.4.0/24","192.168.5.0/24"]
  private_cidr      = [for i in range(3, 6, 1) : cidrsubnet("192.168.0.0/20", 4, i)]
  public_availzone  = ["us-east-1a", "us-east-1b"]
  private_availzone = ["us-east-1d", "us-east-1e", "us-east-1f"]

}

module "database" {
  source = "./rds"
  db_engine_version = "5.7.22"
  db_istorage_type = "gp2"
  db_name = var.db_name
  db_instance_class = "db.t2.micro"
  db_storage = 10
  db_username = var.db_user
  db_password = var.db_password
  db_subnet_group_name = module.networking.db_subnet_group_name
  db_vpc_security_group_ids = module.networking.db_security
  #db_identifier = "shyrdstf"
  skip_final_snapshot = true
}

module "loadbalancer" {
  source = "./LoadBalancer"
  alb_name = "shy-alb-external"
  public_subnets = module.networking.public_subnets
  log_bucket = "service-logs-with-prefix"
  alb_sg = module.networking.public_sg_id
  
  alb_tg_port = var.alb_tg_port
  alb_tg_protocol = var.alb_tg_protocol
  vpc_id = module.networking.vpc_id
  alb_tg_healthythres = var.alb_tg_healthythres
  alb_tg_unhealthythres = var.alb_tg_unhealthythres
  alb_tg_interval = var.alb_tg_interval
  alb_tg_timeout = var.alb_tg_timeout
  alb_listener_port = var.alb_listener_port
  alb_listenet_protocol = var.alb_listenet_protocol
}

module "compute" {
  source = "./compute"
  instance_count = var.instance_count #2
  instance_type = var.instance_type #"t2.micro"
  public_sg = module.networking.public_sg_id
  public_subnet = module.networking.public_subnets
  vol_size = var.vol_size
  aws_lb_target_group_arn = module.loadbalancer.lb_target_group_arn
}