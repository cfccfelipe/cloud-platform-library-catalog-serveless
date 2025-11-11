output "qa_state_bucket_name" {
  description = "S3 bucket name for QA Terraform state"
  value       = module.state_bucket.bucket_name
}

output "qa_lock_table_name" {
  description = "DynamoDB table name for QA state locking"
  value       = module.lock_table.table_name
}
