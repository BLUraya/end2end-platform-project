output "gitlab_id" {
  description = "The id of the gl ec2 "
  value       = aws_instance.gitlab.id
}

output "vault_id" {
  description = "the id of the vaulte ec2"
  value       = aws_instance.vault.id
}

output "ssm_bucket_name" {
  description = "the name of the s3 bucket used for ansible aam transfers"
  value       = aws_s3_bucket.ansible_ssm_bucket.id
}