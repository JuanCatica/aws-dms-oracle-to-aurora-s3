# MODULE: target
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
module "target" {
  source                = "./modules/target"
  region                = var.target_region
  target_db_username    = var.target_db_username
  target_db_password    = var.target_db_password
  target_s3_bucket_name = var.target_s3_bucket_name

  # IMPORTANT:   
  # This params are bound to the source module (related to the source DB) 
  # to easily recreate, deploy and create the resources with just one command
  source_schema_name = module.source.oracle_db_username # @WHAT
  source_db_address  = module.source.oracle_db_address
  source_db_name     = module.source.oracle_db_name
  source_db_port     = module.source.oracle_db_port
  source_db_username = module.source.oracle_db_username
  source_db_password = var.source_db_password

  providers = {
    aws = aws.target
  }
}

# MODULE: source
#   region:                   (required)
#   ec2_ami:                  (required)
#   key_name:                 (required)
#   key_path:                 (required)
#   source_db_username:       (required)
#   source_db_password:       (required)
#   source_db_port:           default 1521
#   source_rds_instance_type: default "db.t3.small"
#   ec2_ami:                  default "ami-"
#   ec2_instance_type:        default "t2.micro"
#   vpc_cidr:                 default "10.0.0.0/16"
#   subnet_cidr_a:            default "10.0.1.0/24"
#   subnet_cidr_b:            default "10.0.2.0/24"
module "source" {
  source   = "./modules/source"
  region   = var.source_region
  ec2_ami  = var.ec2_ami
  key_name = var.key_name
  key_path = var.key_path

  source_db_username = var.source_db_username
  source_db_password = var.source_db_password

  providers = {
    aws = aws.source
  }
}
