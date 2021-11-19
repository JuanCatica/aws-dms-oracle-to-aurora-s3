output "oracle_db_address" {
  value = aws_db_instance.oracle_source.address
}

output "oracle_db_name" {
  value = aws_db_instance.oracle_source.name
}

output "oracle_db_port" {
  value = aws_db_instance.oracle_source.port
}

output "oracle_db_username" {
  value = aws_db_instance.oracle_source.username
}

output "ec2_public_ip" {
  value = aws_instance.ec2_data_generator.public_ip
}
