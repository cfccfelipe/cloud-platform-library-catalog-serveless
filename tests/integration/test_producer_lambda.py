# tests/integration/test_producer_lambda.py
import json
import pytest
from src.lambdas import producer_lambda
from src.lambdas.validation.factory import ValidatorFactory


class FakeSQS:
    """Fake SQS client to capture messages instead of sending to AWS."""
    def __init__(self):
        self.sent_messages = []

    def send_message(self, **kwargs):
        self.sent_messages.append(kwargs)
        return {"MessageId": "msg-123"}


def test_lambda_success(monkeypatch):
    # Patch SQS client
    fake_sqs = FakeSQS()
    monkeypatch.setattr(producer_lambda, "sqs", fake_sqs)
    monkeypatch.setenv("SQS_QUEUE_URL", "https://sqs.local/queue")

    # Prepare event with valid payload
    event = {
        "body": json.dumps({
            "kind": "book_request",
            "payload": {
                "title": "Domain-Driven Design",
                "isbn": "9780321125217",
                "requester_email": "ddd@example.com"
            }
        })
    }

    # Run Lambda handler
    resp = producer_lambda.handler(event, None)
    assert resp["statusCode"] == 200
    assert len(fake_sqs.sent_messages) == 1

    # Validate message body
    body = json.loads(fake_sqs.sent_messages[0]["MessageBody"])
    validator = ValidatorFactory.get_validator("book_request")
    assert validator is not None   # ✅ asegura que no sea None

    validated, errors = validator.validate(body["data"])
    assert errors is None
    assert validated is not None   # ✅ asegura que no sea None
    assert validated["title"] == "Domain-Driven Design"


def test_lambda_invalid_payload(monkeypatch):
    fake_sqs = FakeSQS()
    monkeypatch.setattr(producer_lambda, "sqs", fake_sqs)
    monkeypatch.setenv("SQS_QUEUE_URL", "https://sqs.local/queue")

    # Invalid email
    event = {
        "body": json.dumps({
            "kind": "book_request",
            "payload": {
                "title": "Refactoring",
                "isbn": "9780201485677",
                "requester_email": "not-an-email"
            }
        })
    }

    resp = producer_lambda.handler(event, None)
    assert resp["statusCode"] == 400
    assert len(fake_sqs.sent_messages) == 0


def test_lambda_unknown_kind(monkeypatch):
    fake_sqs = FakeSQS()
    monkeypatch.setattr(producer_lambda, "sqs", fake_sqs)
    monkeypatch.setenv("SQS_QUEUE_URL", "https://sqs.local/queue")

    event = {
        "body": json.dumps({
            "kind": "unknown_kind",
            "payload": {
                "title": "Some Book",
                "isbn": "1234567890",
                "requester_email": "user@example.com"
            }
        })
    }

    resp = producer_lambda.handler(event, None)
    assert resp["statusCode"] == 400
    assert "Unsupported kind" in resp["body"]
    assert len(fake_sqs.sent_messages) == 0


def test_lambda_invalid_json(monkeypatch):
    fake_sqs = FakeSQS()
    monkeypatch.setattr(producer_lambda, "sqs", fake_sqs)
    monkeypatch.setenv("SQS_QUEUE_URL", "https://sqs.local/queue")

    event = {"body": "not-a-json-string"}
    resp = producer_lambda.handler(event, None)
    assert resp["statusCode"] == 400
    assert "Invalid JSON" in resp["body"]
    assert len(fake_sqs.sent_messages) == 0
