resource "aws_security_group" "db_sg" {
  name_prefix = "${var.name}-rds-sg"
  description = "Database Security Group"
  vpc_id      = var.vpc_id

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_security_group_rule" "db_sg_rule" {
  description = "DB Security Group rule to grant DB Port access to the associated source Security Group"
  type                     = "ingress"
  from_port                = var.port
  to_port                  = var.port
  protocol                 = "tcp"
  security_group_id        = aws_security_group.db_sg.id
  source_security_group_id = var.source_sg_id
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
  #checkov:skip=CKV2_AWS_60:Snapshot tag copying is not required for these service databases.
  #checkov:skip=CKV_AWS_118:Enhanced monitoring is not enabled for these service databases.
  #checkov:skip=CKV_AWS_129:Database engine log exports are not required for this deployment.
  #checkov:skip=CKV_AWS_226:Minor engine upgrades are managed through the planned database maintenance process.
  #checkov:skip=CKV_AWS_293:Deletion protection is disabled to allow Terraform-managed environment teardown.
  #checkov:skip=CKV_AWS_353:Performance Insights is not enabled for these service databases.
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
  skip_final_snapshot     = true
}
