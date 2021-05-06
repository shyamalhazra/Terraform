#--Networking/main.tf--#
resource "random_integer" "random" {
  min= 1
  max =5
}
resource "aws_vpc" "shy_vpc" {
  cidr_block = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support = true

  tags = {
    Name = "shy_vpc-${random_integer.random.id}"
  }

}
resource "aws_subnet" "shy_public_subnet" {
  count = length(var.public_cidr)
  cidr_block = var.public_cidr[count.index]
  vpc_id = aws_vpc.shy_vpc.id
  map_public_ip_on_launch = true
  availability_zone = var.public_availzone[count.index]

  tags = {
    Name= "shy_public_subnet-${count.index+1}"
  }
}
resource "aws_route_table_association" "shy_public_association" {
  count = length(var.public_cidr)
  subnet_id = aws_subnet.shy_public_subnet.*.id[count.index]
  route_table_id = aws_route_table.shy-public_rt.id
}
resource "aws_subnet" "shy_private_subnet" {
  count = length(var.private_cidr)
  cidr_block = var.private_cidr[count.index]
  vpc_id = aws_vpc.shy_vpc.id
  availability_zone = var.private_availzone[count.index]

  tags = {
    Name = "shy_private_subnet-${count.index+1}"
  }
}
resource "aws_internet_gateway" "shy_igw" {
  vpc_id = aws_vpc.shy_vpc.id

  tags = {
    Name = "shy_internetateway"
  }
}
resource "aws_route_table" "shy-public_rt" {
  vpc_id = aws_vpc.shy_vpc.id

  tags = {
    Name = "shy_public_route_table"
  }
}
resource "aws_route" "default_route" {
  route_table_id = aws_route_table.shy-public_rt.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id = aws_internet_gateway.shy_igw.id
}
resource "aws_default_route_table" "shy_private_rt" {
  default_route_table_id = aws_vpc.shy_vpc.default_route_table_id
  tags = {
    Name = "shy_private_rt"
  }
}
resource "aws_security_group" "shy_public_sg" {
  name = "shy_public_sg"
  description = "security group for public access"
  vpc_id = aws_vpc.shy_vpc.id
  ingress {
    from_port = 22
    protocol = "tcp"
    to_port = 22
    cidr_blocks = [var.access_ip]
  }
  egress {
    from_port = 0
    protocol = "-1"
    to_port = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "shy_public_securitygroup"
  }
}

resource "aws_security_group_rule" "http_from_anywhere" {
  from_port = 80
  protocol = "tcp"
  security_group_id = aws_security_group.shy_public_sg.id
  to_port = 80
  type = "ingress"
  cidr_blocks = ["0.0.0.0/0"]
}
resource "aws_security_group" "rds_sg" {
  name = "rds_sg"
  description = "security group for mysql access"
  vpc_id = aws_vpc.shy_vpc.id
  ingress {
    from_port = 3306
    protocol = "tcp"
    to_port = 3306
    cidr_blocks = [aws_vpc.shy_vpc.cidr_block]
  }
  tags = {
    Name = "rds_security_group"
  }
}
resource "aws_db_subnet_group" "db_subnet_grp" {
  subnet_ids = aws_subnet.shy_private_subnet.*.id
  name = "shy_rds_subnet_group"

  tags = {
    Name = "Shy rds subnet group"
  }
}