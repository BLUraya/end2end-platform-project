variable "vpc_id" {
  description = "The VPC ID"
  type        = string
}

variable "public_subnets" {
  description = "List of public subnets for the ALB"
  type        = list(string)
}

variable "gitlab_id" {
  description = "The EC2 instance ID for GitLab"
  type        = string
}

variable "vault_id" {
  description = "The EC2 instance ID for Vault"
  type        = string
}