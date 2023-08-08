vpc_id              = "vpc-0a3637e44a9171f10"
public_subnet       = ["subnet-0427fe293a2b1d2f1", "subnet-0652fea07135bfcbf"]
efs_filesystem_id   = "fs-06bd7ccf148a32685"
name                = "bhhan"
environment         = "dev"
aws_region          = "ap-northeast-2"
ami                 = "ami-06d88f849af021b38"
kafka_instance_type = "t3.medium"
instance_key_name   = "bhhan-instance-key"
efs_mount_point     = "efs"
kafka_heap_size     = "500m"
vg_name             = "data"
lv_name             = "volume1"
data_path           = "data"

kafka_instance_values = [
  {
    name         = "kafka1"
    num          = 1
    eip_id       = "eipalloc-0b6886f8c4e01c21e",
    subnet_index = 0,
    kafka_ip     = "52.79.128.142"
  },
  {
    name         = "kafka2"
    num          = 2
    eip_id       = "eipalloc-033901497ef41150b",
    subnet_index = 0,
    kafka_ip     = "43.202.88.106"
  },
  {
    name         = "kafka3"
    num          = 3
    eip_id       = "eipalloc-0d521eb544fb81a30",
    subnet_index = 0,
    kafka_ip     = "15.165.102.243"
  }
]

zookeeper_address = "52.79.222.161:2181,15.165.127.170:2181,43.201.12.56:2181"
device_name       = "/dev/sdh"
ebs_volume_ids    = [
  "vol-0f883ecb9c42a9447",
  "vol-0c5d9dc9c51e2f495",
  "vol-00e4ba8a947bc3639"
]

kafka_ips = [
  "52.79.128.142",
  "43.202.88.106",
  "15.165.102.243"
]
