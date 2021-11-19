output "aurora_db_endpoint" {
  value = aws_rds_cluster.aurora_cluster_target.endpoint
}

output "aurora_db_name" {
  value = aws_rds_cluster.aurora_cluster_target.database_name
}

output "aurora_db_port" {
  value = aws_rds_cluster.aurora_cluster_target.port
}

output "aurora_db_username" {
  value = aws_rds_cluster.aurora_cluster_target.master_username
}

output "s3_bucket_name" {
  value = aws_s3_bucket.bucket_target.id
}
