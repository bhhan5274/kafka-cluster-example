variable "vpc_id" {
  type = string
}

variable "public_subnet" {
  type = list(string)
}

variable "efs_filesystem_id" {
  type = string
}

variable "name" {
  type = string
}

variable "environment" {
  type = string
}

variable "aws_region" {
  type = string
}

variable "ami" {
  type = string
}

variable "kafka_instance_type" {
  type = string
}

variable "instance_key_name" {
  type = string
}

variable "efs_mount_point" {
  type = string
}

variable "kafka_ips" {
  type = list(string)
}

variable "kafka_instance_values" {
  type = list(object({
    name         = string
    num          = number
    subnet_index = number
    eip_id       = string
    kafka_ip     = string
  }))
}

variable "kafka_heap_size" {
  type = string
}

variable "zookeeper_address" {
  type = string
}

variable "device_name" {
  type = string
}

variable "ebs_volume_ids" {
  type = list(string)
}

variable "vg_name" {
  type = string
}

variable "lv_name" {
  type = string
}

variable "data_path" {
  type = string
}
