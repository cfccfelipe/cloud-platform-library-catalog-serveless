# =========================================================================
# MAKEFILE for Serverless Digital Library Catalog (AWS/Terraform/Poetry)
#
# Usage: make <target>
# Targets cover installation, infrastructure, deployment, and cleanup.
# =========================================================================

# --- CONFIGURATION VARIABLES ---
# Reemplace estos valores según su entorno (desarrollo, producción)
AWS_REGION = us-east-1
TERRAFORM_DIR = infra/terraform/environments/qa
LAMBDA_SRC_DIR = src/lambdas
SCRIPTS_DIR = scripts

# Nombre del archivo ZIP de la aplicación para AWS
APP_ZIP_NAME = src/lambda/build/app_deployment.zip
TERRAFORM_PLAN_FILE = tfplan.out

.PHONY: all setup infra deploy clean test zip check ci-test infra-init infra-plan infra-apply infra-destroy

# =========================================================================
# 1. SETUP & UTILITIES (POETRY INTEGRATION)
# =========================================================================

all: setup infra deploy
	@echo "--- ✅ EPIC Deployment Complete ---"
	@echo "Infrastructure is provisioned and application code is deployed."

setup:
	@echo "--- 🛠️ Installing Poetry dependencies ---"
	mkdir -p $(LAMBDA_SRC_DIR)
	mkdir -p $(TERRAFORM_DIR)
	mkdir -p $(SCRIPTS_DIR)
	poetry install
	@echo "Project setup complete via Poetry."


# =========================================================================
# 2. INFRASTRUCTURE AS CODE (Terraform)
# =========================================================================

infra-init:
	@echo "--- 🌍 Initializing Terraform in $(TERRAFORM_DIR) ---"
	cd $(TERRAFORM_DIR) && terraform init

infra-validate: infra-init
	@echo "--- ✅ Validating Terraform configuration ---"
	cd $(TERRAFORM_DIR) && terraform validate

infra-plan: zip infra-validate
	@echo "--- 📝 Generating Terraform plan ---"
	cd $(TERRAFORM_DIR) && terraform plan -var-file=terraform.tfvars -out=$(TERRAFORM_PLAN_FILE)

infra-apply: infra-plan
	@echo "--- 🚀 Applying Infrastructure changes to AWS ---"
	cd $(TERRAFORM_DIR) && terraform apply $(TERRAFORM_PLAN_FILE)

apply: infra-apply
	@echo "--- ✅ Infrastructure applied with packaged Lambda ZIP ---"

infra-destroy:
	@echo "--- ⚠️ Destroying ALL provisioned AWS resources ---"
	@read -p "Are you sure you want to destroy infrastructure? (yes/no): " confirmation; \
	if [ "$$confirmation" = "yes" ]; then \
	    cd $(TERRAFORM_DIR) && terraform destroy -var-file=terraform.tfvars; \
    else \
	    echo "Destruction cancelled."; \
	fi

# =========================================================================
# 3. APPLICATION & DEPLOYMENT
# =========================================================================
zip:
	@echo "--- 📦 Packaging Consumer Lambda source code and dependencies ---"
	mkdir -p infra/terraform/build
	mkdir -p infra/terraform/package

    # Export requirements desde Poetry
	poetry export --without-hashes --without dev -f requirements.txt --output $(SCRIPTS_DIR)/requirements.txt

    # Instalar dependencias en carpeta package (compatibles con Lambda Python 3.12)
	pip3.12 install --upgrade -r $(SCRIPTS_DIR)/requirements.txt --target infra/terraform/package

    # Copiar toda la carpeta src (mantiene imports absolutos)
	cp -r src infra/terraform/package/

    # Crear el zip final para consumer
	cd infra/terraform/package && zip -r ../build/consumer_lambda.zip .
	cd infra/terraform/package && zip -r ../build/producer_lambda.zip .

    # Limpiar temporales
	rm -rf infra/terraform/package
	rm -f $(SCRIPTS_DIR)/requirements.txt

	@echo "✅ Packaging complete: infra/terraform/build/consumer_lambda.zip listo con dependencias incluidas."

deploy: zip infra-apply
	@echo "--- ⬆️ Deploying application code to existing Lambdas ---"
	# Placeholder para comandos AWS CLI
	aws lambda update-function-code --function-name library-fn-producer --zip-file fileb://$(APP_ZIP_NAME) --region $(AWS_REGION)
	aws lambda update-function-code --function-name library-fn-consumer --zip-file fileb://$(APP_ZIP_NAME) --region $(AWS_REGION)
	@echo "Deployment complete. Check CloudWatch logs for verification."


# =========================================================================
# 4. TESTING & QUALITY CHECKS (CI/CD SIMULATION)
# =========================================================================

ci-test: setup
	@echo "--- ⚙️ SIMULATING GITLAB CI BUILD STAGE (LINT/TEST) ---"
	# 1. Linter
	poetry run ruff check .
	# 2. Type
	poetry run mypy .
	# 3. Test unitarias/integración
	$(MAKE) test
	@echo "--- ✅ CI Build Stage Simulation Complete ---"

check:
	@echo "--- 🔍 Running pre-commit hooks (Format, Lint, Types) ---"
	# Check lint, types and test
	$(MAKE) ci-test

test:
	@echo "--- 🧪 Running tests ---"
	poetry run pytest tests/

clean:
	@echo "--- 🗑️ Cleaning local environment files ---"
	rm -f $(APP_ZIP_NAME)
	rm -f $(TERRAFORM_DIR)/$(TERRAFORM_PLAN_FILE)
	rm -f $(SCRIPTS_DIR)/requirements.txt
	find . -type d -name "__pycache__" -exec rm -rf {} +
	@echo "Local cleanup finished."
