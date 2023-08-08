resource "aws_instance" "kafka_instance" {
  for_each = {for instance in var.kafka_instance_values : instance.name => instance}

  ami             = var.ami
  instance_type   = var.kafka_instance_type
  subnet_id       = var.public_subnet[each.value.subnet_index]
  key_name        = var.instance_key_name
  security_groups = [aws_security_group.kafka_instance_sg.id]

  user_data = base64encode(templatefile("${path.module}/kafka-instance.tpl", {
    efs_mount_point   = var.efs_mount_point
    number            = each.value.num
    file_system_id    = var.efs_filesystem_id
    name              = each.value.name
    heap_size         = var.kafka_heap_size
    zookeeper_address = var.zookeeper_address
    kafka_ip          = each.value.kafka_ip
    device            = var.device_name
    vg                = var.vg_name
    lv                = var.lv_name
    data_path         = var.data_path
  }))

  /*root_block_device {
    volume_size = 20
    volume_type = "gp3"
  }*/

  tags = {
    "Name" = each.key
    "Eip"  = each.value.eip_id
    "Number" = each.value.num
  }

  lifecycle {
    ignore_changes = [
      security_groups
    ]
  }
}

resource "aws_security_group" "kafka_instance_sg" {
  name        = "kafka instance security group"
  description = "port 22, 7071, 9100, 9092, 9308, 9999 allow traffic"
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
    from_port   = 9092
    to_port     = 9092
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 7071
    to_port     = 7071
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 9308
    to_port     = 9308
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 9999
    to_port     = 9999
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

resource "aws_eip_association" "eip_kafka_assoc" {
  for_each      = aws_instance.kafka_instance
  instance_id   = each.value.id
  allocation_id = each.value.tags.Eip

  depends_on = [aws_instance.kafka_instance]
}

resource "aws_volume_attachment" "instance_ebs_attachment" {
  for_each    = {for count, instance in aws_instance.kafka_instance : count => instance}
  device_name = var.device_name
  volume_id   = var.ebs_volume_ids[each.value.tags.Number - 1]
  instance_id = each.value.id
}
