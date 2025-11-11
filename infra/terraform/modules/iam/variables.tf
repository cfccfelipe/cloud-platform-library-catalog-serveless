variable "lambda_role_name" {
  description = "Name of the IAM role for the consumer Lambda"
  type        = string
  default     = "consumer-lambda-role"
}

variable "dynamodb_table_arn" {
  description = "ARN of the DynamoDB table"
  type        = string
  default     = null
}

variable "environment" {
  description = "Environment tag (dev, qa, prod)"
  type        = string
  default     = "dev"
}

variable "sqs_main_queue_arn" {
  description = "ARN of the main SQS queue"
  type        = string
  default     = null
}

variable "sqs_dlq_arn" {
  description = "ARN of the Dead Letter Queue"
  type        = string
  default     = null
}

variable "enable_dynamodb" {
  description = "Attach DynamoDB policy"
  type        = bool
  default     = false
}

variable "enable_logs" {
  description = "Attach CloudWatch Logs policy"
  type        = bool
  default     = true
}

variable "enable_sqs_consumer" {
  description = "Attach SQS consumer policy"
  type        = bool
  default     = false
}

variable "enable_sqs_producer" {
  description = "Attach SQS producer policy"
  type        = bool
  default     = false
}
