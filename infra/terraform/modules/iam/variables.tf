# IAM Role name (consumer or producer)
variable "lambda_role_name" {
  description = "Name of the IAM role for the Lambda (consumer or producer)"
  type        = string
}

# Environment tag
variable "environment" {
  description = "Environment tag (dev, qa, prod)"
  type        = string
}

# DynamoDB table ARN (required if enable_dynamodb = true)
variable "dynamodb_table_arn" {
  description = "ARN of the DynamoDB table to be accessed by the Lambda"
  type        = string
  default     = null
}

# SQS main queue ARN (required if enable_sqs_consumer or enable_sqs_producer = true)
variable "sqs_main_queue_arn" {
  description = "ARN of the main SQS queue"
  type        = string
  default     = null
}

# SQS Dead Letter Queue ARN (required if enable_sqs_consumer = true)
variable "sqs_dlq_arn" {
  description = "ARN of the Dead Letter Queue"
  type        = string
  default     = null
}

# Feature flags for policy attachments
variable "enable_dynamodb" {
  description = "Attach DynamoDB policy to Lambda role (consumer requires this)"
  type        = bool
  default     = false
}

variable "enable_logs" {
  description = "Attach CloudWatch Logs policy to Lambda role"
  type        = bool
  default     = true
}

variable "enable_sqs_consumer" {
  description = "Attach SQS consumer policy to Lambda role"
  type        = bool
  default     = false
}

variable "enable_sqs_producer" {
  description = "Attach SQS producer policy to Lambda role"
  type        = bool
  default     = false
}
