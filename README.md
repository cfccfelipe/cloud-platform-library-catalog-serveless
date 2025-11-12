# Serverless Digital Library Catalog EPIC

## 🎯 Overview

This repository contains the final project for the Cloud Platform Engineer specialization. The goal is to deploy a resilient, serverless application on AWS to manage book requests for a digital library catalog. The book requests are submitted via a REST API and are processed asynchronously by a Consumer Lambda before being stored in a database for librarian review.

---
## 🛠️ Technology Stack


| Category                | Component                        | Rationale                                             |
| :---------------------- | :------------------------------- | :---------------------------------------------------- |
| **Backend**             | AWS Lambda (Producer & Consumer) | Serverless compute                                    |
| **API**                 | AWS API Gateway                  | Provides the REST API endpoint                        |
| **Messaging**           | AWS SQS (with DLQ)               | Decoupling and resilience for asynchronous processing |
| **Database**            | AWS DynamoDB                     | Highly available, scalable NoSQL storage              |
| **Infra as Code (IaC)** | Terraform                        | Declarative management of all AWS resources           |
| **Workflow**            | Gitlab Projects, Issues, and PRs | Agile planning and traceability                       |

---
## 🧭 Event-Driven Architecture

  The application follows a simple **Asynchronous Messaging** pattern, structured as follows:

1. **Client Submission:** A user submits a book request (JSON payload) to the **API Gateway**.

2. **Producer Lambda:** The request is handled by the `library-fn-producer`. It validates the data (using **Simple Factory** logic) and sends the message to **SQS**.

3. **SQS Queue:** Holds the message until the Consumer is ready. Includes a **DLQ** for failure handling.

4. **Consumer Lambda:** The `library-fn-consumer` is triggered by the SQS event. It uses the **Facade Pattern** to:

    * Gather additional book details from an external API.

    * Store the final, enriched data in the DynamoDB table.

### 📂 Project Directory Structure

    ├── .github/                      # Gitlab workflow templates (Issues, PRs)
    ├── infra/                        # Infrastructure as Code (IaC)
    │   └── terraform/                # Terraform configuration files (.tf, variables.tf)
    │── src/                          # Application source code (Python)
    │   └── lambdas/                  # Lambda functions (Producer/Consumer handlers)
    │       ├── producer_lambda.py
    │       └── consumer_lambda.py
    ├── tests/                        # Unit and Integration tests
    │   ├── unit/
    │   └── integration/
    ├── scripts/                      # Automation utilities (Used by Makefile)
    │   └── package_lambda.sh         # Script to create deployment ZIP
    ├── docs/                         # Documentation deliverables (Req. 5.b)
    │   └── architecture_explanation.md
    ├── .gitignore                    # Files ignored by Git
    ├── pyproject.toml                # Poetry configuration (Dependencies/Quality Tools)
    ├── Makefile                      # Automation targets (infra-apply, test, deploy)
    └── README.md                     # Project overview

### 📂  Project Architecture Diagram

  [!docs/diagram_arch.png]

---

## ⚙️ Installation

### Prerequisites

1. AWS Account credentials configured locally (via AWS CLI or environment variables).

2. Terraform installed.

3. Python runtime installed

### Steps

1. **Clone the repository:**

```bash

   git clone git@git.epam.com:felipe_cortes/cloud-platform-08-2025-library-catalog-serveless.git

   cd cloud-platform-08-2025-library-catalog-serveless
```

2. **Setup dependencies:**

```bash
    make setup
```

3. **Test and deploy:**

Use the `Makefile` to manage the infrastructure and code deployment lifecycle.

| Command | Purpose |

| Command | Purpose |
| :--- | :--- |
| `make infra-init` | Initializes Terraform backend and modules. |
| `make infra-apply` | Provisions all AWS resources (API GW, Lambdas, SQS, DDB). |
| `make zip` | Packages Lambda code and dependencies for deployment. |
| `make deploy` | Updates Lambda code on AWS (requires `infra-apply` first). |
| `make infra-destroy`| Destroys ALL provisioned AWS resources. |
| `make test` | Runs unit and integration tests. |

---
## 🌳 Contributing

This project strictly follows the **Agile** requirements and **Git best practices**.

* **Repository:** Created on Gitlab.
* **Planning:** All tasks are defined as **Issues** in GitHub Projects.
* **Traceability Chain:** Every code change must be linked as:

This standard defines the precise steps for development, validation, and merging, ensuring continuous quality and traceability.

#### 1. Project Start and Branching

| Step                   | Action                                                                     |
| :--------------------- | :------------------------------------------------------------------------- |
| **1. Create an Issue** | Open a **GitHub Issue** (using the appropriate template) to plan the task. |
| **2. Create a Branch** | Always branch from **`main`**.                                             |
Branch names:

* **`feat`**: New feature  `feature/XX-short-description`
* **`fix`**: Bug correction `bugfix/XX-short-description
* **`chore`**: Maintenance changes `chore/XX-short-description`
* **`refactor`**: Code restructuring without changing functionality. `refactor/XX-short-description`

Commit message:

`Type(Scope): Description #ID` (Atomic and Clear) | `feat(producer): implement data validation #005` |

#### 3. Development and Local Checks

| Step                      | Command                                                    | Purpose                                                                         |
| :------------------------ | :--------------------------------------------------------- | :------------------------------------------------------------------------------ |
| **1. Run Quality Checks** | `make check`                                               | Executes **Ruff**, **Mypy**, and style checks (`pre-commit`) before committing. |
| **2. Create Commits**     | `git commit -m "<type>(<scope>): <short description> #XX"` | **Conventional Commits** (Req. 4.d). The `#XX` links the commit to the Issue.   |
| **3. Run Full Tests**     | `make test`                                                | Confirms all unit and integration tests pass locally.                           |
#### 4. Pull Request (PR) and Merging

| Step                    | Action                                                             | Merge Condition                                            |
| :---------------------- | :----------------------------------------------------------------- | :--------------------------------------------------------- |
| **1. Open a PR**        | Open a **Pull Request** on GitLab.                                 | Req. 1.d: Links code change to PR.                         |
| **2. PR Linking**       | Ensure the PR body contains: `Closes #<issue_id>`                  | **Full Traceability:** Links the PR to the resolved Issue. |
| **3. CI/CD Validation** | The **GitLab CI/CD Pipeline must pass** (Lint, Tests, Infra Plan). | Only green pipelines are eligible for merge (Req. 4.b).    |
| **4. Final Merge**      | Code is merged into the **`main`** branch after reviewer approval. | `main` is the deployment branch.                           |

  ---
## 👨‍💻 Autores

* **Carlos Felipe Cortés** – Initial architecture & development
* **Pedro Cesar Azevedo** – Reviewer & Mentor

---

## 📜 License

This project is licensed under the **MIT License** – see the `LICENSE` file for details.

---
## 📌 Project Status

This project is currently **Active Development** (Final Specialization Challenge). Ensure all **Agile Requirements** (Issues, PRs, Traceability) and **Security Best Practices** are followed.
