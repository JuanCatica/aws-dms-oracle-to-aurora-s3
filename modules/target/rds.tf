resource "aws_rds_cluster" "aurora_cluster_target" {
  cluster_identifier = "aurora-cluster-target"
  engine             = "aurora-postgresql"
  # availability_zones      = ["${var.region}a", "${var.region}b", "${var.region}c"] # @HARDCODED @WHAT: Usando "${var.region}c" o "${var.region}d" falla.
  database_name           = "DBTARGET" # @HARDCODED
  master_username         = var.target_db_username
  master_password         = var.target_db_password
  port                    = var.target_db_port
  skip_final_snapshot     = true
  apply_immediately       = true
  db_subnet_group_name    = aws_db_subnet_group.subnet_group_target.name
  vpc_security_group_ids  = [aws_security_group.allow_public_target.id]
  backup_retention_period = 1

  tags = {
    Name    = "aurora_cluster_target"
    project = "oracle2aurora"
  }
}

resource "aws_rds_cluster_instance" "aurora_instance1" {
  apply_immediately   = true
  cluster_identifier  = aws_rds_cluster.aurora_cluster_target.id
  identifier          = "instance1"
  instance_class      = var.target_rds_instance_type
  engine              = aws_rds_cluster.aurora_cluster_target.engine
  engine_version      = aws_rds_cluster.aurora_cluster_target.engine_version
  publicly_accessible = true

  tags = {
    Name    = "aurora_instance1"
    project = "oracle2aurora"
  }
}

resource "aws_rds_cluster_endpoint" "aurora_endpoint_target" {
  cluster_identifier          = aws_rds_cluster.aurora_cluster_target.id
  cluster_endpoint_identifier = "reader-writer"
  custom_endpoint_type        = "ANY"

  static_members = [
    aws_rds_cluster_instance.aurora_instance1.id,
  ]

  tags = {
    Name    = "aurora_endpoint_target"
    project = "oracle2aurora"
  }
}

resource "aws_db_subnet_group" "subnet_group_target" {
  name       = "subnet-group-target"
  subnet_ids = [aws_subnet.subnet_target_a.id, aws_subnet.subnet_target_b.id]

  tags = {
    Name    = "subnet_group_target"
    project = "oracle2aurora"
  }
}
