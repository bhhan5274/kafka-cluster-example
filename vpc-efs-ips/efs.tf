resource "aws_efs_file_system" "efs_file_system" {
  creation_token   = "kafka-test"
  performance_mode = "generalPurpose"
  throughput_mode  = "bursting"

  lifecycle_policy {
    transition_to_ia = "AFTER_30_DAYS"
  }

  tags = local.tags
}

resource "aws_security_group" "efs_sg" {
  name        = "EFS Security Group"
  description = "Allow traffic from inside vpc resources only"
  vpc_id      = module.vpc.vpc_id

  ingress {
    from_port   = 2049
    to_port     = 2049
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = local.tags
}

resource "aws_efs_mount_target" "mount_target1" {
  file_system_id  = aws_efs_file_system.efs_file_system.id
  subnet_id       = module.vpc.public_subnet_id[0]
  security_groups = [aws_security_group.efs_sg.id]
}

resource "aws_efs_mount_target" "mount_target2" {
  file_system_id  = aws_efs_file_system.efs_file_system.id
  subnet_id       = module.vpc.public_subnet_id[1]
  security_groups = [aws_security_group.efs_sg.id]
}
