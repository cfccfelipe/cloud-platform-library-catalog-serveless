provider "aws" {
  region  = var.aws_region
  profile = var.aws_profile   # optional: allows using AWS_PROFILE without hardcoding credentials
}

# S3 bucket for remote Terraform state
module "state_bucket" {
  source      = "../../modules/s3"
  bucket_name = var.state_bucket_name
  environment = var.environment
}

# DynamoDB table for state locking
module "lock_table" {
  source        = "../../modules/dynamodb"
  table_name    = var.lock_table_name
  billing_mode  = "PAY_PER_REQUEST"   # explicit for clarity
  hash_key      = "LockID"            # explicit even if default
  hash_key_type = "S"
  environment   = var.environment
  # ttl_attribute_name left empty → no TTL
}

# DynamoDB table for catalog requests
module "catalog_table" {
  source             = "../../modules/dynamodb"
  table_name         = var.catalog_table_name
  billing_mode       = "PAY_PER_REQUEST"
  hash_key           = "id"
  hash_key_type      = "S"
  environment        = var.environment
  ttl_attribute_name = "expire_at"
}

# IAM Role + Policies for the consumer Lambda
module "consumer_lambda_iam" {
  source             = "../../modules/iam"
  lambda_role_name   = "consumer-lambda-role-${var.environment}"
  dynamodb_table_arn = module.catalog_table.table_arn
  environment        = var.environment
}

# SQS Main Queue + Dead Letter Queue (DLQ)
module "sqs" {
  source                = "../../modules/sqs"
  environment           = var.environment
  main_queue_name       = "book-requests-queue"
  dlq_name              = "book-requests-dlq"
  visibility_timeout    = 60
  max_receive_count     = 3
  dlq_retention_seconds = 1209600
}
