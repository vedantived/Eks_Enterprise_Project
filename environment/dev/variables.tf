variable "project_name" {
  type = string
}

variable "aws_region" {
  type = string
}

variable "vpc_cidr" {
  type = string
}

variable "public_subnet_cidrs" {
  type = list(string)
}

variable "private_app_subnet_cidrs" {
  type = list(string)
}

variable "instance_type" {
  type = string
}

variable "app_port" {
  type = number
}


variable "desired_capacity" {
  type = number
}

variable "min_size" {
  type = number
}

variable "max_size" {
  type = number
}
variable "common_tags" {
  type = map(string)
}