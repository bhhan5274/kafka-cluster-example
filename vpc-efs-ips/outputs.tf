output "vpc_id" {
  value = module.vpc.vpc_id
}

output "public_subnets" {
  value = module.vpc.public_subnet_id
}

output "efs_filesystem_id" {
  value = aws_efs_file_system.efs_file_system.id
}

output "eip_zookeeper_ids" {
  value = aws_eip.zookeeper_instance_eip.*.id
}

output "eip_zookeeper_public_ips" {
  value = aws_eip.zookeeper_instance_eip.*.public_ip
}

output "eip_kafka_ids" {
  value = aws_eip.kafka_instance_eip.*.id
}

output "eip_kafka_public_ips" {
  value = aws_eip.kafka_instance_eip.*.public_ip
}
