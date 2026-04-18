variable "vpc_id" {
  description = "the ID of the vpc"
  type        = string
}

variable "private_subnets" {
  description = "list of private subnets for the EKS worker nodes"
  type        = list(string)
}