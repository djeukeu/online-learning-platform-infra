output "auth_db" {
  value = {
    endpoint = module.auth_db.endpoint
    username = module.auth_db.username
    db_name  = module.auth_db.db_name
    port     = module.auth_db.port
  }
}

output "payment_db" {
  value = {
    endpoint = module.payment_db.endpoint
    username = module.payment_db.username
    db_name  = module.payment_db.db_name
    port     = module.payment_db.port
  }
}

output "course_db" {
  value = {
    endpoint = module.course_db.endpoint
    username = module.course_db.username
    db_name  = module.course_db.db_name
    port     = module.course_db.port
  }
}



