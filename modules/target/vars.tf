# ------------------------------
# MODULE: cloud
# VARIABLES:
#   region:             (required)
#   source_schema_name: (required)
#   source_db_address:  (required)
#   source_db_name:     (required)
#   source_db_port:     (required)
#   source_db_username: (required)
#   source_db_password: (required)
#   target_db_username: (required)
#   target_db_password: (required)
#   target_db_port:     default 1521
#   vpc_cidr:           default "10.0.0.0/16"
#   subnet_cidr_a:      default "10.0.1.0/24"
#   subnet_cidr_b:      default "10.0.2.0/24"
#   subnet_cidr_c:      default "10.0.2.0/24"

variable "region" {}

variable "source_schema_name" {}

variable "source_db_address" {}

variable "source_db_name" {}

variable "source_db_port" {}

variable "source_db_username" {}

variable "source_db_password" {}

variable "target_s3_bucket_name" {}

variable "target_db_username" {}

variable "target_db_password" {}

variable "target_db_port" {
  default = 5432
}

variable "vpc_cidr" {
  default = "10.2.0.0/16"
}

variable "subnet_cidr_a" {
  default = "10.2.1.0/24"
}

variable "subnet_cidr_b" {
  default = "10.2.2.0/24"
}

variable "subnet_cidr_c" {
  default = "10.2.3.0/24"
}

variable "target_rds_instance_type" {
  default = "db.t3.medium"
}
