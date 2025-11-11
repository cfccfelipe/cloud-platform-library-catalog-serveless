provider "aws" {
  region = var.aws_region
}

module "state_bucket" {
  source      = "../../modules/s3"
  bucket_name = var.state_bucket_name
  environment = "qa"
}

module "lock_table" {
  source      = "../../modules/dynamodb"
  table_name  = var.lock_table_name
  environment = "qa"
}
