variable "environment" {
  description = "Environment tag (dev, qa, prod)"
  type        = string
}

variable "main_queue_name" {
  description = "Base name of the main SQS queue (without environment prefix)"
  type        = string
  default     = "book-requests-queue"
}

variable "dlq_name" {
  description = "Base name of the Dead Letter Queue (without environment prefix)"
  type        = string
  default     = "book-requests-dlq"
}

variable "visibility_timeout" {
  description = "Visibility timeout for the main queue in seconds"
  type        = number
  default     = 60
}

variable "max_receive_count" {
  description = "Maximum number of times a message is received before moving to DLQ"
  type        = number
  default     = 3
}

variable "dlq_retention_seconds" {
  description = "Retention period for messages in DLQ (seconds, default 14 days)"
  type        = number
  default     = 1209600
}
