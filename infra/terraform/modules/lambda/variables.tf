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
  # default     = "lambda_function.lambda_handler"  # 👈 neutral default
}

variable "runtime" {
  description = "Lambda runtime"
  type        = string
  default     = "python3.12"  # 👈 actualizado
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

# 🔑 Extra variables for SQS event source mapping
variable "sqs_main_queue_arn" {
  description = "ARN of the main SQS queue"
  type        = string
  default     = null   # 👈 opcional
}

variable "batch_size" {
  description = "Number of messages to batch per Lambda trigger"
  type        = number
  default     = 10
}

variable "enable_sqs_consumer" {
  description = "Whether to create an event source mapping for SQS"
  type        = bool
  default     = false
}
