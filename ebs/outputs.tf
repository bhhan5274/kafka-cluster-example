output "ebs_ids" {
  value = aws_ebs_volume.instance_ebs.*.id
}
