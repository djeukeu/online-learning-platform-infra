output "db_secret_arn" {
  value = aws_db_instance.db_instance.master_user_secret[0].secret_arn
}

output "db_name" {
  value = aws_db_instance.db_instance.db_name
}

output "db_address" {
  value = aws_db_instance.db_instance.address
}

output "db_port" {
  value = aws_db_instance.db_instance.port
}

output "db_security_group_id" {
  value = aws_security_group.db_sg.id
}
