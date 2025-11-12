variable "project_name" {
  description = "Project base name"
  type        = string
}

variable "environment" {
  description = "Environment tag (dev, qa, prod)"
  type        = string
}

variable "aws_region" {
  description = "AWS region"
  type        = string
}

variable "producer_lambda_arn" {
  description = "ARN of the Producer Lambda"
  type        = string
}

variable "producer_lambda_name" {
  description = "Name of the Producer Lambda"
  type        = string
}

# modules/api_gateway/variables.tf
variable "apigw_cloudwatch_role_arn" {
  description = "IAM role ARN for API Gateway to push logs to CloudWatch"
  type        = string
}
