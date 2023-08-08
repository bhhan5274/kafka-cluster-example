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

variable "zookeeper_instance_type" {
  type = string
}

variable "instance_key_name" {
  type = string
}

variable "efs_mount_point" {
  type = string
}

variable "zookeeper_ips" {
  type = list(string)
}

variable "zookeeper_instance_values" {
  type = list(object({
    name = string
    number = string
    eip_id = string
    subnet_index = number
  }))
}
