resource "aws_ebs_volume" "instance_ebs" {
  count             = var.ebs_count
  availability_zone = "ap-northeast-2a"
  size              = 8
  type              = "gp3"
}
