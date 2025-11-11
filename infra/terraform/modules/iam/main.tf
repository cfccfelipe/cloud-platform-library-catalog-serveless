# IAM Role for Lambda
resource "aws_iam_role" "consumer_lambda_role" {
  name = var.lambda_role_name

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })

  tags = {
    Environment = var.environment
    Name        = var.lambda_role_name
  }
}

# IAM Policy for DynamoDB access
resource "aws_iam_policy" "consumer_lambda_dynamodb_policy" {
  name        = "${var.lambda_role_name}-dynamodb-policy"
  description = "Allow Consumer Lambda to access only the catalog table"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = [
          "dynamodb:GetItem",
          "dynamodb:PutItem",
          "dynamodb:UpdateItem",
          "dynamodb:Query",
          "dynamodb:Scan"
        ]
        Resource = var.dynamodb_table_arn
      }
    ]
  })
}

# IAM Policy for CloudWatch Logs
resource "aws_iam_policy" "consumer_lambda_logs_policy" {
  name        = "${var.lambda_role_name}-logs-policy"
  description = "Allow Consumer Lambda to write logs to CloudWatch"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = "arn:aws:logs:*:*:*"
      }
    ]
  })
}

# Attach policies to role
resource "aws_iam_role_policy_attachment" "consumer_lambda_dynamodb_attach" {
  role       = aws_iam_role.consumer_lambda_role.name
  policy_arn = aws_iam_policy.consumer_lambda_dynamodb_policy.arn
}

resource "aws_iam_role_policy_attachment" "consumer_lambda_logs_attach" {
  role       = aws_iam_role.consumer_lambda_role.name
  policy_arn = aws_iam_policy.consumer_lambda_logs_policy.arn
}
