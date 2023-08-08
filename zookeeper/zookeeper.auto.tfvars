vpc_id                  = "vpc-0a3637e44a9171f10"
public_subnet           = ["subnet-0427fe293a2b1d2f1", "subnet-0652fea07135bfcbf"]
efs_filesystem_id       = "fs-06bd7ccf148a32685"
name                    = "bhhan"
environment             = "dev"
aws_region              = "ap-northeast-2"
ami                     = "ami-06d88f849af021b38"
zookeeper_instance_type = "t2.micro"
instance_key_name       = "bhhan-instance-key"
efs_mount_point         = "efs"

zookeeper_instance_values = [
  {
    name         = "zookeeper1"
    number       = "1"
    eip_id       = "eipalloc-09f0c72cb5c599f29"
    subnet_index = 0
  },
  {
    name         = "zookeeper2"
    number       = "2"
    eip_id       = "eipalloc-0c5db145fcbbf90ea"
    subnet_index = 0
  },
  {
    name         = "zookeeper3"
    number       = "3"
    eip_id       = "eipalloc-0e5e19310339e126f"
    subnet_index = 0
  }
]

zookeeper_ips = [
  "52.79.222.161",
  "15.165.127.170",
  "43.201.12.56"
]
