resource "aws_security_group" "db_sg" {
  name   = "${var.app_name}-sg"
  vpc_id = var.vpc_id

  ingress {
    from_port   = var.db_port
    to_port     = var.db_port
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_db_subnet_group" "db_subnets" {
  name       = "${var.app_name}-db-subnet"
  subnet_ids = var.subnet_ids
}

resource "aws_db_instance" "my_db" {
  db_name                 = "${var.app_name}_db"
  username                = var.db_username
  password                = var.db_password
  engine                  = var.db_engine
  engine_version          = var.db_engine_version
  port                    = var.db_port
  instance_class          = var.rds_instance_class
  backup_retention_period = 5
  allocated_storage       = 10
  identifier              = var.app_name
  db_subnet_group_name    = aws_db_subnet_group.db_subnets.name
  multi_az                = true
  publicly_accessible     = true
  vpc_security_group_ids  = [aws_security_group.db_sg.id]
  skip_final_snapshot     = true
}
