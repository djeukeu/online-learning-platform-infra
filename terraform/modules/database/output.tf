output "endpoint" {
  value = aws_db_instance.my_db.address
}

output "username" {
  value = aws_db_instance.my_db.username
}

output "db_name" {
  value = aws_db_instance.my_db.db_name
}

output "port" {
  value = aws_db_instance.my_db.port
}

