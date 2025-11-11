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
  billing_mode  = "PAY_PER_REQUEST"
  hash_key      = "LockID"
  hash_key_type = "S"
  environment   = var.environment
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

# SQS Main Queue + Dead Letter Queue (DLQ)
module "sqs" {
  source                = "../../modules/sqs"
  environment           = var.environment
  main_queue_name       = var.main_queue_name
  dlq_name              = var.dlq_name
  visibility_timeout    = 60
  max_receive_count     = 3
  dlq_retention_seconds = 1209600
}

# IAM Role + Policies for the consumer Lambda
module "consumer_lambda_iam" {
  source             = "../../modules/iam"
  lambda_role_name   = "consumer-lambda-role-${var.environment}"
  dynamodb_table_arn = module.catalog_table.table_arn
  sqs_main_queue_arn = module.sqs.main_queue_arn
  sqs_dlq_arn        = module.sqs.dlq_arn
  environment        = var.environment
}

# IAM Role + Policy for the producer Lambda (send-only)
module "producer_lambda_iam" {
  source             = "../../modules/iam"
  lambda_role_name   = "producer-lambda-role-${var.environment}"
  sqs_main_queue_arn = module.sqs.main_queue_arn
  environment        = var.environment
}

# Producer Lambda function
module "producer_lambda" {
  source               = "../../modules/lambda"
  environment          = var.environment

  lambda_function_name = "${var.environment}-library-fn-producer"
  lambda_role_arn      = module.producer_lambda_iam.lambda_role_arn
  filename             = var.producer_lambda_package
  handler              = "producer_lambda.lambda_handler"
  runtime              = "python3.9"

  environment_variables = {
    SQS_QUEUE_URL = module.sqs.main_queue_url
  }
}
