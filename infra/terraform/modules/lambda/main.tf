# Lambda Function (no IAM inside this module)
resource "aws_lambda_function" "lambda" {
  function_name = var.lambda_function_name
  role          = var.lambda_role_arn   # IAM role passed in from external IAM module
  handler       = var.handler
  runtime       = var.runtime

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
