#Networking/outputs
output "vpc_id" {
  value = aws_vpc.shy_vpc.id
}
output "public_sg_id" {
  value = aws_security_group.shy_public_sg.*.id
}
output "db_subnet_group_name" {
  value = aws_db_subnet_group.db_subnet_grp.name
}
output "db_security" {
  value = aws_security_group.rds_sg.*.id
}
output "public_subnets" {
  value = aws_subnet.shy_public_subnet.*.id
}