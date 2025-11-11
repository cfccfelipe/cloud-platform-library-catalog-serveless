variable "aws_region" {
  description = "AWS region to deploy resources"
  type        = string
  default     = "us-east-1"
}

variable "aws_profile" {
  description = "AWS CLI profile to use"
  type        = string
  default     = "default"
}

variable "environment" {
  description = "Environment tag (dev, qa, prod)"
  type        = string
  default     = "qa"
}

variable "state_bucket_name" {
  description = "Name of the S3 bucket for Terraform state"
  type        = string
}

variable "lock_table_name" {
  description = "Name of the DynamoDB table for state locking"
  type        = string
}

variable "catalog_table_name" {
  description = "Name of the DynamoDB catalog table"
  type        = string
  default     = "library-catalog-requests-table"
}

variable "main_queue_name" {
  description = "Base name of the main SQS queue"
  type        = string
  default     = "book-requests-queue"
}

variable "dlq_name" {
  description = "Base name of the Dead Letter Queue"
  type        = string
  default     = "book-requests-dlq"
}
