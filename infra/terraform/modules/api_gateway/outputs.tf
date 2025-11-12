output "api_id" {
  description = "API Gateway ID"
  value       = aws_api_gateway_rest_api.rest.id
}

output "invoke_url" {
  description = "Base invoke URL for the API Gateway stage"
  value       = "https://${aws_api_gateway_rest_api.rest.id}.execute-api.${var.aws_region}.amazonaws.com/${aws_api_gateway_stage.stage.stage_name}"
}

output "execution_arn" {
  description = "Execution ARN of the API Gateway"
  value       = aws_api_gateway_rest_api.rest.execution_arn
}
