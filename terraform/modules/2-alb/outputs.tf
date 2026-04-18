output "alb_dns_name" {
  description = "the dns for the main alb"
  value       = aws_lb.main.dns_name
}