output "vpc_id" {
  description = "the ID of the vpc"
  value       = module.vpc.vpc_id
}

output "private_subnets" {
  description = "list of IDs private subnets"
  value       = module.vpc.private_subnets
}

output "public_subnets" {
  description = "list of IDs public subnets"
  value = module.vpc.public_subnets
}