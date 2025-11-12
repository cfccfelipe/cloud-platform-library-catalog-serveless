output "apigw_cloudwatch_role_name" {
  description = "Name of the API Gateway CloudWatch role"
  value       = aws_iam_role.apigw_cloudwatch.name
}

output "apigw_cloudwatch_role_arn" {
  description = "ARN of the API Gateway CloudWatch role"
  value       = aws_iam_role.apigw_cloudwatch.arn
}
