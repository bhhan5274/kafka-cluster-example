resource "aws_eip" "kafka_instance_eip" {
  count = var.kafka_eip_count
  vpc   = true
}
