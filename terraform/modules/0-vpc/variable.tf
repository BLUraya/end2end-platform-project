variable "aws_region" {
  description = "aws region for the infrastructure"
  type        = string
  default     = "eu-central-1" 
}

variable "vpc_cidr" {
  description = "cidr block for vpc"
  type        = string
  default     = "10.0.0.0/16"
}