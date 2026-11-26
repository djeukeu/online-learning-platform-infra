locals {
  default_log_exports = {
    postgres      = ["postgresql", "upgrade"]
    mysql         = ["error", "slowquery"]
    mariadb       = ["error", "slowquery"]
    oracle-ee     = ["alert", "audit", "listener"]
    oracle-se2    = ["alert", "audit", "listener"]
    sqlserver-ee  = ["agent", "error"]
    sqlserver-se  = ["agent", "error"]
    sqlserver-ex  = ["agent", "error"]
    sqlserver-web = ["agent", "error"]
  }
}
