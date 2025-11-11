# =========================================================================
# MAKEFILE for Serverless Digital Library Catalog (AWS/Terraform/Poetry)
#
# Usage: make <target>
# Targets cover installation, infrastructure, deployment, and cleanup.
# =========================================================================

# --- CONFIGURATION VARIABLES ---
# Reemplace estos valores según su entorno (desarrollo, producción)
AWS_REGION = us-east-1
TERRAFORM_DIR = infra/terraform
LAMBDA_SRC_DIR = src/lambdas
SRC_DIR = src/
SCRIPTS_DIR = scripts

# Nombre del archivo ZIP de la aplicación para AWS
APP_ZIP_NAME = deployment_package.zip
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

infra-plan: infra-init
	@echo "--- 📝 Generating Terraform plan ---"
	cd $(TERRAFORM_DIR) && terraform plan -out=$(TERRAFORM_PLAN_FILE)

infra-apply: infra-plan
	@echo "--- 🚀 Applying Infrastructure changes to AWS ---"
	cd $(TERRAFORM_DIR) && terraform apply $(TERRAFORM_PLAN_FILE)

infra-destroy:
	@echo "--- ⚠️ Destroying ALL provisioned AWS resources ---"
	@read -p "Are you sure you want to destroy infrastructure? (yes/no): " confirmation; \
	if [ "$$confirmation" = "yes" ]; then \
		cd $(TERRAFORM_DIR) && terraform destroy; \
	else \
		echo "Destruction cancelled."; \
	fi


# =========================================================================
# 3. APPLICATION & DEPLOYMENT
# =========================================================================

zip:
	@echo "--- 📦 Packaging Lambda source code and dependencies ---"
	poetry export --without dev -f requirements.txt --output $(SCRIPTS_DIR)/requirements.txt
	chmod +x ./scripts/package_lambda.sh
	@echo "Running packaging script to include dependencies in the ZIP..."
	./$(SCRIPTS_DIR)/package_lambda.sh $(LAMBDA_SRC_DIR) $(APP_ZIP_NAME) $(SCRIPTS_DIR)/requirements.txt

	rm -f $(SCRIPTS_DIR)/requirements.txt
	@echo "Packaging complete and temporary files cleaned up."

deploy: zip infra-apply
	@echo "--- ⬆️ Deploying application code to existing Lambdas ---"
	# Placeholder para comandos AWS CLI
	aws lambda update-function-code --function-name library-fn-producer --zip-file fileb://$(APP_ZIP_NAME) --region $(AWS_REGION)
	aws lambda update-function-code --function-name library-fn-consumer --zip-file fileb://$(APP_ZIP_NAME) --region $(AWS_REGION)
	@echo "Deployment complete. Check CloudWatch logs for verification."


# =========================================================================
# 4. TESTING & QUALITY CHECKS (CI/CD SIMULATION)
# =========================================================================

# Nuevo Target: Simula el job de linting y pruebas en el pipeline de CI/CD
ci-test: setup
	@echo "--- ⚙️ SIMULATING GITLAB CI BUILD STAGE (LINT/TEST) ---"
	# 1. Linter
	poetry run ruff check .
	# 2. Type
	poetry run mypy .
	# 3. Pruebas unitarias/integración
	$(MAKE) test
	@echo "--- ✅ CI Build Stage Simulation Complete ---"

check:
	@echo "--- 🔍 Running pre-commit hooks (Format, Lint, Types) ---"
	# Check lint, types and test
	$(MAKE) ci-test

test:
	@echo "--- 🧪 Running tests ---"
	poetry run pytest $(SRC_DIR)/tests/

clean:
	@echo "--- 🗑️ Cleaning local environment files ---"
	rm -f $(APP_ZIP_NAME)
	rm -f $(TERRAFORM_DIR)/$(TERRAFORM_PLAN_FILE)
	rm -f $(SCRIPTS_DIR)/requirements.txt
	find . -type d -name "__pycache__" -exec rm -rf {} +
	@echo "Local cleanup finished."
