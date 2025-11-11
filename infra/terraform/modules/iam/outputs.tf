output "lambda_role_name" {
  description = "Name of the IAM role for the consumer Lambda"
  value       = aws_iam_role.consumer_lambda_role.name
}

output "lambda_role_arn" {
  description = "ARN of the IAM role for the consumer Lambda"
  value       = aws_iam_role.consumer_lambda_role.arn
}

output "dynamodb_policy_arn" {
  description = "ARN of the DynamoDB access policy"
  value       = aws_iam_policy.consumer_lambda_dynamodb_policy.arn
}

output "logs_policy_arn" {
  description = "ARN of the CloudWatch Logs policy"
  value       = aws_iam_policy.consumer_lambda_logs_policy.arn
}
