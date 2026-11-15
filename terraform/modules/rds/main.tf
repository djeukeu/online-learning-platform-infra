resource "aws_security_group" "db_sg" {
  name_prefix = "${var.name}-rds-sg"
  vpc_id      = var.vpc_id

  lifecycle {
    create_before_destroy = true
  }
}


resource "aws_db_subnet_group" "db_subnets" {
  name       = "${var.name}-db-subnet"
  subnet_ids = var.subnet_ids
}

resource "aws_secretsmanager_secret_rotation" "example" {
  secret_id           = aws_db_instance.db_instance.master_user_secret[0].secret_arn

  rotation_rules {
    automatically_after_days = 30
  }
}

resource "aws_db_instance" "db_instance" {
  identifier     = var.name
  engine         = var.engine
  instance_class = var.instance_class
  port           = var.port

  allocated_storage     = 10
  max_allocated_storage = 20
  storage_encrypted     = true

  db_name  = "${var.name}_db"
  username = "${var.name}_user"

  manage_master_user_password   = true

  db_subnet_group_name   = aws_db_subnet_group.db_subnets.name
  vpc_security_group_ids = [aws_security_group.db_sg.id]
  publicly_accessible    = false

  multi_az                = true
  backup_retention_period = 7
  skip_final_snapshot     = true
}
