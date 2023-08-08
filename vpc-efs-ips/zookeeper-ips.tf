resource "aws_eip" "zookeeper_instance_eip" {
  count = var.zookeeper_eip_count
  vpc   = true
}
