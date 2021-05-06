#...compute/main.tf..

data "aws_ami" "amzn-ec2-ami" {
  most_recent = true
  owners = ["137112412989"]

  filter {
    name = "name"
    values = ["amzn2-ami-hvm-2.0.*.0-x86_64-gp2"]
  }
}

resource "aws_instance" "ec2-node" {
  count = var.instance_count
  ami = data.aws_ami.amzn-ec2-ami.id
  instance_type = var.instance_type
  vpc_security_group_ids = var.public_sg
  subnet_id = var.public_subnet[count.index]
  root_block_device {
    volume_size = var.vol_size
  }
  key_name = "GoldenKP"
  #user_data = ""
  tags = {
    Name = "shy-ec2-${count.index +1}"
  }
}
resource "aws_lb_target_group_attachment" "shy-tg-attach" {
  count = var.instance_count
  target_group_arn = var.aws_lb_target_group_arn
  target_id = aws_instance.ec2-node[count.index].id
}