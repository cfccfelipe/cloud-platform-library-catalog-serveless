# AWS provider
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

# Remote state backend
variable "state_bucket_name" {
  description = "Name of the S3 bucket for Terraform state"
  type        = string
}

variable "lock_table_name" {
  description = "Name of the DynamoDB table for state locking"
  type        = string
}

# DynamoDB catalog table
variable "catalog_table_name" {
  description = "Name of the DynamoDB catalog table"
  type        = string
  default     = "library-catalog-requests-table"
}

# SQS queues
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

# Producer Lambda
variable "producer_lambda_function_name" {
  description = "Name of the producer Lambda function"
  type        = string
  default     = "library-fn-producer"
}

variable "producer_lambda_role_name" {
  description = "Name of the IAM role for the producer Lambda"
  type        = string
  default     = "library-fn-producer-role"
}

variable "producer_lambda_package" {
  description = "Path to the deployment package zip file for producer Lambda"
  type        = string
  default     = "../../build/producer_lambda.zip"
}

# Consumer Lambda (optional, si quieres parametrizar también desde root)
variable "consumer_lambda_function_name" {
  description = "Name of the consumer Lambda function"
  type        = string
  default     = "library-fn-consumer"
}

variable "consumer_lambda_role_name" {
  description = "Name of the IAM role for the consumer Lambda"
  type        = string
  default     = "library-fn-consumer-role"
}
