resource "aws_instance" "zookeeper_instance" {
  for_each = {for instance in var.zookeeper_instance_values : instance.name => instance}

  ami             = var.ami
  instance_type   = var.zookeeper_instance_type
  subnet_id       = var.public_subnet[each.value.subnet_index]
  key_name        = var.instance_key_name
  security_groups = [aws_security_group.zookeeper_instance_sg.id]

  user_data = base64encode(templatefile("${path.module}/zookeeper-instance.tpl", {
    efs_mount_point = var.efs_mount_point
    number          = each.value.number
    file_system_id  = var.efs_filesystem_id
    name            = each.value.name
    server_name     = each.value.number
    server_1        = each.value.number == "1" ? "0.0.0.0" : var.zookeeper_ips[0]
    server_2        = each.value.number == "2" ? "0.0.0.0" : var.zookeeper_ips[1]
    server_3        = each.value.number == "3" ? "0.0.0.0" : var.zookeeper_ips[2]
  }))

  /*root_block_device {
    volume_size = 8
    volume_type = "gp3"
  }*/

  tags = {
    "Name" = each.key
    "Eip"  = each.value.eip_id
  }

  lifecycle {
    ignore_changes = [
      security_groups
    ]
  }
}

resource "aws_security_group" "zookeeper_instance_sg" {
  name        = "zookeeper instance security group"
  description = "port 22, 2181, 7000, 2888, 3888, 9100 allow traffic"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 9100
    to_port     = 9100
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 2181
    to_port     = 2181
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 7000
    to_port     = 7000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 2888
    to_port     = 2888
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 3888
    to_port     = 3888
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    "Name"        = var.name
    "Environment" = var.environment
  }
}

resource "aws_eip_association" "eip_zookeeper_assoc" {
  for_each      = aws_instance.zookeeper_instance
  instance_id   = each.value.id
  allocation_id = each.value.tags.Eip

  depends_on = [aws_instance.zookeeper_instance]
}
