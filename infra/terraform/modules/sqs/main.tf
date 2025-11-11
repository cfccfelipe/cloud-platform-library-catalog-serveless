# Dead Letter Queue (DLQ)
resource "aws_sqs_queue" "dlq" {
  name                      = "${var.environment}-${var.dlq_name}"
  message_retention_seconds = var.dlq_retention_seconds

  tags = {
    Environment = var.environment
    Purpose     = "DeadLetterQueue"
  }
}

# Main SQS Queue
resource "aws_sqs_queue" "main" {
  name                       = "${var.environment}-${var.main_queue_name}"
  visibility_timeout_seconds = var.visibility_timeout

  redrive_policy = jsonencode({
    deadLetterTargetArn = aws_sqs_queue.dlq.arn
    maxReceiveCount     = var.max_receive_count
  })

  tags = {
    Environment = var.environment
    Purpose     = "MainQueue"
  }
}
