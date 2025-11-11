# 📚 Style Guide and Conventions: Serverless Library Catalog

## 📌 Methodology and Scope

This guide establishes the conventions for naming, architecture, and code for the **Library Catalog Serverless** project, ensuring **end-to-end traceability** (Git $\rightarrow$ Issues $\rightarrow$ PRs $\rightarrow$ Infrastructure) and adherence to Serverless best practices.

---

## 🛠️ Naming Conventions

We will use the format **`library-<service>-<purpose>`** for all main resources, prioritizing clarity for IAM auditing and log management.

| Resource | Convention | Example | Requirement |
| :--- | :--- | :--- | :--- |
| **Lambda Function** | `library-fn-<purpose>` | `library-fn-producer`, `library-fn-consumer` | 2.a, 3.b.ii |
| **DynamoDB Table** | `library-ddb-<name>` | `library-ddb-book-requests` | 3.b.iv |
| **SQS Queue** | `library-sqs-<purpose>` | `library-sqs-requests`, `library-sqs-requests-dlq` | 3.b.iii |
| **API Gateway** | `library-apigw-<domain>` | `library-apigw-book-requests` | 3.b.i |
| **IAM Role** | `library-role-<purpose>` | `library-role-lambda-producer` | 3.b.vi |
| **CloudWatch Log Group**| `/aws/lambda/library-fn-<purpose>` | `/aws/lambda/library-fn-producer` | 3.b.v |

---

## 🌳 Git Strategy and Agile Traceability

A **Feature Branching** workflow will be used where **all activity is traceable** to a GitHub Issue.

| Element | Convention | Requirement |
| :--- | :--- | :--- |
| **Main Branch** | `main` (Protected) | 4.d |
| **Feature Branch** | `feature/<issue-id>-<short-description>` | 1.b |
| **Commit Message**| `Type(Scope): Description #ID` (Atomic) | 4.d |
| **Pull Request (PR)** | The PR must link and close the Issue. | 1.c, 1.d |

---

## 🧠 Applied Architectural Patterns

The solution is built on **decoupling principles** (EDA) and **separation of concerns** (SRP) using specific design patterns.

| Pattern | Application in Project | Structural Benefit |
| :--- | :--- | :--- |
| **EDA / Async Messaging** | API Gateway $\rightarrow$ **SQS** $\rightarrow$ Consumer Lambda. | **Decouples** request reception from processing, guaranteeing message delivery (resilience). |
| **Simple Factory** | Implemented in the **Producer Lambda** to handle validation and structuring of the input JSON. | Centralizes data validation (Req. 2.b.ii) before queuing. |
| **Facade** | Implemented in the **Consumer Lambda** to abstract the logic for calling the external API (Req. 2.c.ii) and writing to DynamoDB (Req. 2.c.iii). | Simplifies the Consumer function, focusing it solely on the SQS event handling. |
| **Circuit Breaker** (Design) | Principles applied in *timeout* and *retry* logic when the Consumer calls the external API. | Protects the Serverless system against external third-party service failures. |
| **Least Privilege** | IAM Policies are strictly defined for the required action (e.g., Producer only has `sqs:SendMessage`). | 4.c |

---

## 💻 Code and Serverless Conventions

| Aspect | Convention | Requirement Covered |
| :--- | :--- | :--- |
| **Logic Separation** | Lambdas must adhere to **Single Responsibility** (Produce or Consume/Process). | 2.a, SRP |
| **Validation** | The **Producer Lambda** must validate data before queuing (Simple Factory). | 2.b.ii |
| **Consumer** | The **Consumer Lambda** must properly handle SQS *batching* and failure management so messages are moved to the **DLQ**. | 3.b.iii, EDA |
