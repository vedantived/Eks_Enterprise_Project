variable "cluster_name" {
  type = string
}

variable "cluster_role_arn" {
  type = string
}

variable "subnet_ids" {
  type = list(string)
}

variable "allowed_cidrs" {
  type = list(string)
}

variable "cluster_role_policy_attachment" {
  type = any
}

variable "tags" {
  type = map(string)
}