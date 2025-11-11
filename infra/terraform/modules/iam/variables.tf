variable "lambda_role_name" {
  description = "Name of the IAM role for the consumer Lambda"
  type        = string
  default     = "consumer-lambda-role"
}

variable "dynamodb_table_arn" {
  description = "ARN of the DynamoDB table the Lambda can access"
  type        = string
}

variable "environment" {
  description = "Environment tag (dev, qa, prod)"
  type        = string
  default     = "dev"
}
