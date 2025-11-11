output "qa_state_bucket_name" {
  description = "S3 bucket name for QA Terraform state"
  value       = module.state_bucket.bucket_name
}

output "qa_state_bucket_arn" {
  description = "S3 bucket ARN for QA Terraform state"
  value       = module.state_bucket.bucket_arn
}

output "qa_lock_table_name" {
  description = "DynamoDB table name for QA state locking"
  value       = module.lock_table.table_name
}

output "qa_lock_table_arn" {
  description = "DynamoDB table ARN for QA state locking"
  value       = module.lock_table.table_arn
}

output "qa_catalog_table_name" {
  description = "DynamoDB table name for QA catalog requests"
  value       = module.catalog_table.table_name
}

output "qa_catalog_table_arn" {
  description = "DynamoDB table ARN for QA catalog requests"
  value       = module.catalog_table.table_arn
}
