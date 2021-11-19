# --------------
# MODULE: target

output "target-addr" {
  value = module.target.aurora_db_endpoint
}

output "target-port" {
  value = module.target.aurora_db_port
}

output "target-name" {
  value = module.target.aurora_db_name
}

output "target-user" {
  value = module.target.aurora_db_username
}

# --------------
# MODULE: source

output "source-addr" {
  value = module.source.oracle_db_address
}

output "source-port" {
  value = module.source.oracle_db_port
}

output "source-name" {
  value = module.source.oracle_db_name
}

output "source-user" {
  value = module.source.oracle_db_username
}

output "ssh-data-generator" { #IMPORTANTE
  value = "ssh -i ${var.key_path} ec2-user@${module.source.ec2_public_ip}"
}

# ------------------------
# MODULE: aurora-migration

output "dms-task-aurora-arn" {
  value = module.target.aurora_db_username #@WRONG
}

output "dms-endpoint-aurora-arn" {
  value = module.target.aurora_db_username #@WRONG
}

# --------------------
# MODULE: s3-migration

output "dms-task-s3-arn" {
  value = module.target.aurora_db_username #@WRONG
}

output "dms-endpoint-s3-arn" {
  value = module.target.aurora_db_username #@WRONG
}
