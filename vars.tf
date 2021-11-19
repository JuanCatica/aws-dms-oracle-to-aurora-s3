# Create a .tfvars and define:
# ec2_ami = ""
# target_db_username = ""
# target_db_password = ""
# source_db_username = "" 
# source_db_password = ""
# target_db_username = ""
# target_db_password = ""


# -----------------------------------
# SOURCE
variable "source_region" {
  default = "us-west-2"
}

variable "ec2_ami" {}

variable "key_name" {}

variable "key_path" {}

variable "source_db_username" {}

variable "source_db_password" {}


# -----------------------------------
# TARGET
variable "target_region" {
  default = "us-east-1"
}

variable "target_s3_bucket_name" {}

variable "target_db_username" {}

variable "target_db_password" {}
