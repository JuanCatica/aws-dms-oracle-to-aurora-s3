resource "aws_db_instance" "oracle_source" {
  identifier     = "oracledb-source"
  instance_class = var.source_rds_instance_type
  engine         = "oracle-se2"
  engine_version = "12.2.0.1.ru-2018-10.rur-2018-10.r1"
  license_model  = "license-included"

  storage_type                    = "gp2"
  allocated_storage               = 20
  max_allocated_storage           = 25
  multi_az                        = false
  name                            = "DBSOURCE" # @HARDCODED
  username                        = var.source_db_username
  password                        = var.source_db_password
  port                            = var.source_db_port
  skip_final_snapshot             = true
  apply_immediately               = true
  publicly_accessible             = true
  db_subnet_group_name            = aws_db_subnet_group.subnet_group_source.name
  vpc_security_group_ids          = [aws_security_group.allow_public_source.id]
  enabled_cloudwatch_logs_exports = ["alert", "audit", "listener", "trace"]
  backup_retention_period         = 1
  monitoring_interval             = 0

  tags = {
    Name    = "oracle_source"
    project = "oracle2aurora"
  }
}

resource "aws_db_subnet_group" "subnet_group_source" {
  name = "subnet-group-source"
  subnet_ids = [
    aws_subnet.subnet_source_a.id,
    aws_subnet.subnet_source_b.id
  ]

  tags = {
    Name    = "subnet_group_source"
    project = "oracle2aurora"
  }
}
