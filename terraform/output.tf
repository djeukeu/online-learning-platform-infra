output "auth_db" {
  value = {
    endpoint = module.auth_db.endpoint
    username = module.auth_db.username
    db_name  = module.auth_db.db_name
    port     = module.auth_db.port
  }
}



