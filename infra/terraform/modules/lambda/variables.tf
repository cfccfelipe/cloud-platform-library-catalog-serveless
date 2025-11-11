variable "lambda_function_name" {
  description = "Name of the Lambda function"
  type        = string
}

variable "lambda_role_arn" {
  description = "ARN of the IAM role for the Lambda"
  type        = string
}

variable "handler" {
  description = "Lambda handler (module.function)"
  type        = string
  default     = "producer_lambda.lambda_handler"
}

variable "runtime" {
  description = "Lambda runtime"
  type        = string
  default     = "python3.9"
}

variable "filename" {
  description = "Path to the Lambda deployment package zip"
  type        = string
}

variable "environment_variables" {
  description = "Environment variables for the Lambda"
  type        = map(string)
  default     = {}
}

variable "environment" {
  description = "Environment tag (dev, qa, prod)"
  type        = string
}
