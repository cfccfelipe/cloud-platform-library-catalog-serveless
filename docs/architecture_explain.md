# 🏛️ Architecture Explanation: Serverless Digital Library Catalog

## 1. Design Overview

This system is built using an **Event-Driven Architecture (EDA)** approach on AWS, focusing on **decoupling** and **resilience**. The core principle is to separate the high-volume, synchronous intake of book requests (via API Gateway) from the slower, resource-intensive processing (external API lookups and database storage).

### Key Architectural Principles
* **Decoupling:** Achieved by using **SQS** as a buffer between the Producer and the Consumer. This protects the Consumer Lambda from traffic spikes and ensures message delivery (Req. 3.b.iii).
* **Single Responsibility Principle (SRP):** Two distinct Lambda functions are used to manage the intake and processing phases separately (Req. 2.a).
* **Least Privilege:** All IAM roles are strictly scoped to the necessary actions (e.g., the Producer Lambda can *only* send messages to SQS).

---

## 2. Component Diagram and Data Flow

The following image illustrates the data flow and interaction between the components of our serverless system.

[!diagram_arch.png]

### A. Producer (Synchronous Intake)
As shown in the diagram, this phase handles the user request intake:
| Component | Role | Logic/Pattern |
| :--- | :--- | :--- |
| **User** | **Initiator** | Sends a book request in JSON format to the system. |
| **API Gateway** | **Inbound Adapter** | Exposes a single REST endpoint (`POST /request`) that receives the user's JSON payload. |
| **Producer Lambda** | **Data Validation & Enqueuing** | 1. Receives the JSON payload. 2. Validates and restructures the data (**Simple Factory Pattern**). 3. Sends the validated payload to the SQS queue (Req. 2.b.iii). |

### B. Consumer (Asynchronous Processing)
Continuing the flow shown in the diagram:
| Component | Role | Logic/Pattern |
| :--- | :--- | :--- |
| **SQS Queue** | **Buffer / Durability** | Stores raw book requests. The associated **Dead Letter Queue (DLQ)** ensures handling of failed messages. |
| **Consumer Lambda** | **Business Logic Execution** | 1. Triggered by the SQS event. 2. Consults an **external Book API** to gather additional information (Req. 2.c.ii). 3. Uses the **Facade Pattern** to manage the external API interaction and DynamoDB storage. 4. Stores the enriched data in the DynamoDB table (Req. 2.c.iii). |
| **Book API** | **External Data Source** | Provides detailed metadata for the requested book. |
| **DynamoDB** | **Persistence** | Stores the final, enriched request result for later librarian review. The diagram illustrates an example of the stored data format. |

---

## 3. Infrastructure as Code (IaC)

All resources are managed by **Terraform/Pulumi** (Req. 3.a) to ensure a reproducible and reliable deployment process.

| Resource Group | Requirements Covered | Security Note (Req. 4.c) |
| :--- | :--- | :--- |
| **Compute** | Two Lambda functions (Producer & Consumer), CloudWatch Log Groups. | The **Consumer IAM Role** must allow `dynamodb:PutItem` and outbound HTTPS requests. |
| **Messaging** | SQS Queue and SQS Dead Letter Queue (DLQ). | The **Producer IAM Role** must only allow `sqs:SendMessage` on the primary queue ARN. |
| **Data & API** | DynamoDB Table and API Gateway configuration. | **API Gateway** uses a secure integration method (Lambda Proxy or IAM/Resource Policy). |
