variable "table_name" {
  description = "Name of the DynamoDB table"
  type        = string
}

variable "billing_mode" {
  description = "Billing mode for DynamoDB (PAY_PER_REQUEST or PROVISIONED)"
  type        = string
  default     = "PAY_PER_REQUEST" # On-Demand Capacity Mode
}

variable "hash_key" {
  description = <<EOT
Primary hash key name.
Default "LockID" is for the Terraform state lock table.
Override with "id" for the catalog table.
EOT
  type    = string
  default = "LockID"
}

variable "hash_key_type" {
  description = "Type of the hash key (S, N, B)"
  type        = string
  default     = "S"
}

variable "environment" {
  description = "Environment tag"
  type        = string
  default     = "dev"
}

variable "ttl_attribute_name" {
  description = <<EOT
Attribute used for TTL expiration.
Leave empty to disable.
Use "expire_at" for catalog table to enable TTL.
EOT
  type    = string
  default = ""
}
