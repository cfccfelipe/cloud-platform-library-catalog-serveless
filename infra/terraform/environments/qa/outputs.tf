# S3
output "qa_state_bucket_name" {
  description = "S3 bucket name for QA Terraform state"
  value       = module.state_bucket.bucket_name
}

output "qa_state_bucket_arn" {
  description = "S3 bucket ARN for QA Terraform state"
  value       = module.state_bucket.bucket_arn
}

# DynamoDB Lock Table
output "qa_lock_table_name" {
  description = "DynamoDB table name for QA state locking"
  value       = module.lock_table.table_name
}

output "qa_lock_table_arn" {
  description = "DynamoDB table ARN for QA state locking"
  value       = module.lock_table.table_arn
}

# DynamoDB Catalog Table
output "qa_catalog_table_name" {
  description = "DynamoDB table name for QA catalog requests"
  value       = module.catalog_table.table_name
}

output "qa_catalog_table_arn" {
  description = "DynamoDB table ARN for QA catalog requests"
  value       = module.catalog_table.table_arn
}

# IAM Role for Consumer Lambda
output "qa_consumer_lambda_role_name" {
  description = "IAM role name for the consumer Lambda"
  value       = module.consumer_lambda_iam.lambda_role_name
}

output "qa_consumer_lambda_role_arn" {
  description = "IAM role ARN for the consumer Lambda"
  value       = module.consumer_lambda_iam.lambda_role_arn
}

# SQS Queues
output "qa_sqs_main_queue_name" {
  description = "Main SQS queue name"
  value       = module.sqs.main_queue_name
}

output "qa_sqs_main_queue_arn" {
  description = "Main SQS queue ARN"
  value       = module.sqs.main_queue_arn
}

output "qa_sqs_dlq_name" {
  description = "Dead Letter Queue name"
  value       = module.sqs.dlq_name
}

output "qa_sqs_dlq_arn" {
  description = "Dead Letter Queue ARN"
  value       = module.sqs.dlq_arn
}
