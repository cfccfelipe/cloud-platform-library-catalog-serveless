# src/lambdas/producer_lambda.py
import json
import os
from typing import Any

import boto3
from aws_lambda_typing.context import Context

from src.lambdas.validation.factory import ValidatorFactory

sqs = boto3.client("sqs")
QUEUE_URL = os.getenv("SQS_QUEUE_URL", "")


def lambda_handler(event: dict[str, Any], context: Context | None) -> dict[str, Any]:
    try:
        body = event.get("body")
        data: dict[str, Any] = json.loads(body) if isinstance(body, str) else body or {}
    except Exception:
        return {"statusCode": 400, "body": json.dumps({"error": "Invalid JSON"})}

    kind = data.get("kind", "book_request")
    payload = data.get("payload", {})

    validator = ValidatorFactory.get_validator(kind)
    if not validator:
        return {
            "statusCode": 400,
            "body": json.dumps({"error": f"Unsupported kind: {kind}"}),
        }

    validated, errors = validator.validate(payload)
    if errors:
        return {"statusCode": 400, "body": json.dumps({"errors": errors})}

    message = {
        "kind": kind,
        "data": validated,
        "meta": {"source": "library-fn-producer"},
    }

    sqs.send_message(QueueUrl=QUEUE_URL, MessageBody=json.dumps(message))
    return {"statusCode": 200, "body": json.dumps({"status": "ok"})}
