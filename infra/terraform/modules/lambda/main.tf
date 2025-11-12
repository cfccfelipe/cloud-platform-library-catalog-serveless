# Lambda Function (no IAM inside this module)
resource "aws_lambda_function" "lambda" {
  function_name = var.lambda_function_name
  role          = var.lambda_role_arn   # IAM role passed in from external IAM module
  handler       = var.handler
  runtime       = var.runtime
  timeout       = 10
  filename         = var.filename
  source_code_hash = filebase64sha256(var.filename)

  environment {
    variables = var.environment_variables
  }

  tags = {
    Environment = var.environment
    Name        = var.lambda_function_name
  }
}

resource "aws_lambda_event_source_mapping" "sqs_consumer" {
  count            = var.enable_sqs_consumer ? 1 : 0
  event_source_arn = var.sqs_main_queue_arn
  function_name    = aws_lambda_function.lambda.function_name  # 👈 más claro
  batch_size       = var.batch_size
  enabled          = true

  depends_on = [aws_lambda_function.lambda]
}

