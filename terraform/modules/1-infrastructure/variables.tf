variable "vpc_id" {
  description = "the ID of the vpc from the vpc module"
  type        = string
}

variable "private_subnet_ids" {
  description = "list of private subnet ids for the instances"
  type        = list(string)
}