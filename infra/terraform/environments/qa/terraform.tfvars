aws_region  = "us-east-1"
aws_profile = "default"   # opcional, cámbialo si usas otro perfil en AWS CLI

environment = "qa"

# Remote state backend
state_bucket_name = "company-qa-terraform-state"
lock_table_name   = "company-qa-terraform-locks"

# Catalog table
catalog_table_name = "library-catalog-requests-qa"

# SQS queues
main_queue_name = "book-requests-queue"
dlq_name        = "book-requests-dlq"
enable_sqs_producer = true
enable_sqs_consumer = true
enable_logs = true

# Lambda Producer
producer_lambda_function_name = "qa-library-fn-producer"
producer_lambda_role_name     = "qa-library-fn-producer-role"
producer_lambda_package       = "../../build/producer_lambda.zip"

# Lambda Consumer
consumer_lambda_function_name = "qa-library-fn-consumer"
consumer_lambda_role_name     = "qa-library-fn-consumer-role"
