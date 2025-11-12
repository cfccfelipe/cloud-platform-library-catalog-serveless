# IAM Role for Lambda (consumer or producer)
resource "aws_iam_role" "lambda_role" {
  name = var.lambda_role_name

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = { Service = "lambda.amazonaws.com" }
    }]
  })

  tags = {
    Environment = var.environment
    Name        = var.lambda_role_name
  }
}

# DynamoDB Policy (required for consumer Lambda)
resource "aws_iam_policy" "lambda_dynamodb_policy" {
  count       = var.enable_dynamodb ? 1 : 0
  name        = "${var.lambda_role_name}-dynamodb-policy"
  description = "Allow Lambda to access DynamoDB table"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = [
          "dynamodb:GetItem",
          "dynamodb:PutItem",
          "dynamodb:UpdateItem",
          "dynamodb:DeleteItem",
          "dynamodb:Query",
          "dynamodb:Scan"
        ]
        Resource = var.dynamodb_table_arn
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_dynamodb_attach" {
  count      = var.enable_dynamodb ? 1 : 0
  role       = aws_iam_role.lambda_role.name
  policy_arn = aws_iam_policy.lambda_dynamodb_policy[0].arn
}

# CloudWatch Logs Policy (optional)
resource "aws_iam_policy" "lambda_logs_policy" {
  count       = var.enable_logs ? 1 : 0
  name        = "${var.lambda_role_name}-logs-policy"
  description = "Allow Lambda to write logs to CloudWatch"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect   = "Allow"
      Action   = [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ]
      Resource = "arn:aws:logs:*:*:*"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_logs_attach" {
  count      = var.enable_logs ? 1 : 0
  role       = aws_iam_role.lambda_role.name
  policy_arn = aws_iam_policy.lambda_logs_policy[0].arn
}

# SQS Consumer Policy (optional)
resource "aws_iam_policy" "lambda_sqs_consumer_policy" {
  count       = var.enable_sqs_consumer ? 1 : 0
  name        = "${var.lambda_role_name}-sqs-consumer-policy"
  description = "Allow Lambda to consume messages from SQS and send to DLQ"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = [
          "sqs:ReceiveMessage",
          "sqs:DeleteMessage",
          "sqs:GetQueueAttributes"
        ]
        Resource = var.sqs_main_queue_arn
      },
      {
        Effect   = "Allow"
        Action   = ["sqs:SendMessage"]
        Resource = var.sqs_dlq_arn
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_sqs_consumer_attach" {
  count      = var.enable_sqs_consumer ? 1 : 0
  role       = aws_iam_role.lambda_role.name
  policy_arn = aws_iam_policy.lambda_sqs_consumer_policy[0].arn
}

# SQS Producer Policy (optional)
resource "aws_iam_policy" "lambda_sqs_producer_policy" {
  count       = var.enable_sqs_producer ? 1 : 0
  name        = "${var.lambda_role_name}-sqs-producer-policy"
  description = "Allow Lambda to send messages to SQS"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect   = "Allow"
      Action   = ["sqs:SendMessage"]
      Resource = var.sqs_main_queue_arn
    }]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_sqs_producer_attach" {
  count      = var.enable_sqs_producer ? 1 : 0
  role       = aws_iam_role.lambda_role.name
  policy_arn = aws_iam_policy.lambda_sqs_producer_policy[0].arn
}
