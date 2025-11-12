# Lambda role outputs
output "lambda_role_name" {
  description = "Name of the Lambda IAM role"
  value       = aws_iam_role.lambda_role.name
}

output "lambda_role_arn" {
  description = "ARN of the Lambda IAM role"
  value       = aws_iam_role.lambda_role.arn
}

# Optional policy outputs
output "dynamodb_policy_arn" {
  description = "ARN of the DynamoDB policy (if created)"
  value       = try(aws_iam_policy.lambda_dynamodb_policy[0].arn, null)
}

output "logs_policy_arn" {
  description = "ARN of the CloudWatch Logs policy (if created)"
  value       = try(aws_iam_policy.lambda_logs_policy[0].arn, null)
}

output "sqs_consumer_policy_arn" {
  description = "ARN of the SQS consumer policy (if created)"
  value       = try(aws_iam_policy.lambda_sqs_consumer_policy[0].arn, null)
}

output "sqs_producer_policy_arn" {
  description = "ARN of the SQS producer policy (if created)"
  value       = try(aws_iam_policy.lambda_sqs_producer_policy[0].arn, null)
}


