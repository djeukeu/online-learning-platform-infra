output "vpc-id" {
  value       = aws_vpc.vpc.id
  description = "The unique identifier of the VPC"
}
