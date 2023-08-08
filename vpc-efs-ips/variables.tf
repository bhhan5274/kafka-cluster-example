variable "name" {
  type = string
}

variable "environment" {
  type = string
}

variable "aws_region" {
  type = string
}

variable "vpc_cidr" {
  type = string
}

variable "azs" {
  type = list(string)
}

variable "public_subnet_cidr" {
  type = list(string)
}

variable "enable_single_nat_gateway" {
  type = bool
}

variable "zookeeper_eip_count" {
  type = number
}

variable "kafka_eip_count" {
  type = number
}
