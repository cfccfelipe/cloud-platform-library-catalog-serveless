output "lambda_function_name" {
  description = "Name of the Lambda function"
  value       = aws_lambda_function.lambda.function_name
}

output "lambda_function_arn" {
  description = "ARN of the Lambda function"
  value       = aws_lambda_function.lambda.arn
}

output "lambda_event_source_mapping_id" {
  description = "ID of the Lambda event source mapping"
  value       = var.enable_sqs_consumer ? one(aws_lambda_event_source_mapping.sqs_consumer[*].id) : null
}

output "lambda_event_source_mapping_uuid" {
  description = "UUID of the Lambda event source mapping"
  value       = var.enable_sqs_consumer ? one(aws_lambda_event_source_mapping.sqs_consumer[*].uuid) : null
}
