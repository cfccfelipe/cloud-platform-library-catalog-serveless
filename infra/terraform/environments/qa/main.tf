provider "aws" {
  region  = var.aws_region
  profile = var.aws_profile
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
  source               = "../../modules/iam"
  lambda_role_name     = "consumer-lambda-role-${var.environment}"
  environment          = var.environment

  enable_sqs_consumer  = var.enable_sqs_consumer
  dynamodb_table_arn   = module.catalog_table.table_arn
  sqs_main_queue_arn   = module.sqs.main_queue_arn
  sqs_dlq_arn          = module.sqs.dlq_arn
  enable_logs          = var.enable_logs
}

module "consumer_lambda" {
  source               = "../../modules/lambda"
  environment          = var.environment
  lambda_function_name = "${var.environment}-library-fn-consumer"
  lambda_role_arn      = module.consumer_lambda_iam.lambda_role_arn
  filename             = var.consumer_lambda_package
  handler              = "src.lambdas.consumer_lambda.lambda_handler"
  runtime              = "python3.12"

  environment_variables = {
    SQS_QUEUE_URL      = module.sqs.main_queue_url
    CATALOG_TABLE_NAME = var.catalog_table_name
  }

  # Event source mapping config
  sqs_main_queue_arn     = module.sqs.main_queue_arn
  batch_size             = 10
  maximum_retry_attempts = 3
  enabled                = true
}

# IAM Role + Policy for the producer Lambda (send-only)
module "producer_lambda_iam" {
  source              = "../../modules/iam"
  lambda_role_name    = "producer-lambda-role-${var.environment}"
  sqs_main_queue_arn  = module.sqs.main_queue_arn
  environment         = var.environment
  enable_sqs_producer = var.enable_sqs_producer
}

# Producer Lambda function
module "producer_lambda" {
  source               = "../../modules/lambda"
  environment          = var.environment

  lambda_function_name = "${var.environment}-library-fn-producer"
  lambda_role_arn      = module.producer_lambda_iam.lambda_role_arn
  filename             = var.producer_lambda_package
  handler              = "src.lambdas.producer_lambda.lambda_handler"
  runtime              = "python3.12"

  environment_variables = {
    SQS_QUEUE_URL = module.sqs.main_queue_url
  }
}

module "apigw_cloudwatch_iam" {
  source      = "../../modules/apigw_cloudwatch_iam"
  environment = var.environment
}

module "api_gateway" {
  source               = "../../modules/api_gateway"
  project_name         = "library-catalog"
  environment          = var.environment
  aws_region           = var.aws_region
  producer_lambda_arn  = module.producer_lambda.lambda_function_arn
  producer_lambda_name = module.producer_lambda.lambda_function_name

  apigw_cloudwatch_role_arn = module.apigw_cloudwatch_iam.apigw_cloudwatch_role_arn
}
