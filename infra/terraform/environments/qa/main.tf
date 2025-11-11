provider "aws" {
  region  = var.aws_region
  profile = var.aws_profile   # opcional: permite usar AWS_PROFILE sin hardcodear credenciales
}

module "state_bucket" {
  source      = "../../modules/s3"
  bucket_name = var.state_bucket_name
  environment = var.environment
}

module "lock_table" {
  source        = "../../modules/dynamodb"
  table_name    = var.lock_table_name
  billing_mode  = "PAY_PER_REQUEST"   # explícito para claridad
  hash_key      = "LockID"            # explícito aunque sea el default
  hash_key_type = "S"
  environment   = var.environment
  # ttl_attribute_name queda vacío → sin TTL
}

module "catalog_table" {
  source             = "../../modules/dynamodb"
  table_name         = var.catalog_table_name
  billing_mode       = "PAY_PER_REQUEST"
  hash_key           = "id"
  hash_key_type      = "S"
  environment        = var.environment
  ttl_attribute_name = "expire_at"
}

module "consumer_lambda_iam" {
  source            = "../../modules/iam"
  lambda_role_name  = "consumer-lambda-role-qa"
  dynamodb_table_arn = module.catalog_table.table_arn
  environment       = "qa"
}
