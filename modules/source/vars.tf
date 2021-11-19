# ------------------------------
# MODULE: source
# VARIABLES:
#   region:                   (required)
#   ec2_ami:                  (required)
#   source_db_username:       (required)
#   source_db_password:       (required)
#   source_db_port:           default 1521
#   source_rds_instance_type: default "db.t3.small"
#   ec2_ami:                  default "ami-013a129d325529d4d"
#   ec2_instance_type:        default "t2.micro"
#   vpc_cidr:                 default "10.0.0.0/16"
#   subnet_cidr_a:            default "10.0.1.0/24"
#   subnet_cidr_b:            default "10.0.2.0/24"

variable "region" {}

variable "ec2_ami" {}

variable "key_name" {}

variable "key_path" {}

variable "source_db_username" {}

variable "source_db_password" {}

variable "source_db_port" {
  default = 1521
}

variable "source_rds_instance_type" {
  default = "db.t3.small"
}

variable "ec2_instance_type" {
  default = "t2.micro"
}

variable "vpc_cidr" {
  default = "10.0.0.0/16"
}

variable "subnet_cidr_a" {
  default = "10.0.1.0/24"
}

variable "subnet_cidr_b" {
  default = "10.0.2.0/24"
}
