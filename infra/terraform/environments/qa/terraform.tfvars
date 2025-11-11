# terraform.tfvars for QA environment

aws_region        = "us-east-1"
aws_profile       = "default"   # opcional, cámbialo si usas otro perfil en AWS CLI

environment       = "qa"

# Remote state backend
state_bucket_name = "company-qa-terraform-state"
lock_table_name   = "company-qa-terraform-locks"

# Catalog table
catalog_table_name = "library-catalog-requests-qa"

