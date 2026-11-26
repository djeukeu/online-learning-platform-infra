resource "aws_security_group" "db_sg" {
  name_prefix = "${var.name}-rds-sg"
  description = "Database Security Group"
  vpc_id      = var.vpc_id

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_db_subnet_group" "db_subnets" {
  name       = "${var.name}-db-subnet"
  subnet_ids = var.subnet_ids
}

resource "aws_secretsmanager_secret_rotation" "rds_secret_rotation" {
  secret_id = aws_db_instance.db_instance.master_user_secret[0].secret_arn

  rotation_rules {
    automatically_after_days = 30
  }
}

resource "aws_db_instance" "db_instance" {
  #checkov:skip=CKV_AWS_161:IAM database authentication is not used by these service applications.
  #checkov:skip=CKV_AWS_226:Minor engine upgrades are managed through the planned database maintenance process.
  #checkov:skip=CKV_AWS_293:Deletion protection is disabled to allow Terraform-managed environment teardown.
  #checkov:skip=CKV_AWS_354:Performance Insights uses AWS-managed encryption; a customer-managed KMS key is not configured.
  #checkov:skip=CKV2_AWS_30:Database query logging is not enabled for these service databases.
  identifier     = var.name
  engine         = var.engine
  instance_class = var.instance_class
  port           = var.port

  allocated_storage     = 10
  max_allocated_storage = 20
  storage_encrypted     = true

  db_name  = "${var.name}_db"
  username = "${var.name}_user"

  manage_master_user_password = true

  db_subnet_group_name   = aws_db_subnet_group.db_subnets.name
  vpc_security_group_ids = [aws_security_group.db_sg.id]
  publicly_accessible    = false

  multi_az                = true
  backup_retention_period = 7
  backup_window           = "02:00-03:00"
  maintenance_window      = "sun:04:00-sun:05:00"
  copy_tags_to_snapshot   = true
  skip_final_snapshot     = true

  database_insights_mode                = "standard"
  performance_insights_enabled          = true
  performance_insights_retention_period = 7

  monitoring_interval = 60
  monitoring_role_arn = aws_iam_role.rds_monitoring.arn

  enabled_cloudwatch_logs_exports = local.default_log_exports[var.engine]

  depends_on = [
    aws_iam_role_policy_attachment.rds_monitoring,
    aws_cloudwatch_log_group.rds_log_group,
  ]

}
