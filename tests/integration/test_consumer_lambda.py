import json
import pytest
from src.lambdas import consumer_lambda
from src.lambdas.storage.base import StorageAdapter
from src.lambdas.validation.factory import ValidatorFactory


class FakeStorageAdapter(StorageAdapter):
    """Fake storage adapter to capture writes instead of hitting DynamoDB."""
    def __init__(self):
        self.items = []

    def put_item(self, item: dict) -> None:
        self.items.append(item)


@pytest.fixture
def patched_storage(monkeypatch):
    """Fixture que inyecta FakeStorageAdapter y setea env var requerida."""
    fake_storage = FakeStorageAdapter()
    # Inyectamos el fake en consumer_lambda
    monkeypatch.setattr(consumer_lambda, "storage", fake_storage)
    # Seteamos la env var requerida
    monkeypatch.setenv("CATALOG_TABLE_NAME", "fake-table")
    return fake_storage


def test_consumer_lambda_success(patched_storage):
    payload = {
        "kind": "book_request",
        "payload": {
            "title": "Clean Architecture",
            "isbn": "9780134494166",
            "requester_email": "uncle.bob@example.com"
        }
    }
    event = {
        "Records": [
            {"messageId": "msg-123", "body": json.dumps(payload)}
        ]
    }

    resp = consumer_lambda.lambda_handler(event, None)
    assert resp["status"] == "processed"
    assert len(resp["results"]["success"]) == 1
    assert patched_storage.items[0]["title"] == "Clean Architecture"


    # Validación con factory
    validator = ValidatorFactory.get_validator("book_request")
    assert validator is not None
    validated, errors = validator.validate(payload["payload"])
    assert errors is None
    assert validated is not None
    assert validated["isbn"] == "9780134494166"


def test_consumer_lambda_invalid_payload(patched_storage):
    payload = {
        "kind": "book_request",
        "payload": {
            "title": "",  # inválido
            "isbn": "",
            "requester_email": "not-an-email"
        }
    }
    event = {
        "Records": [
            {"messageId": "msg-456", "body": json.dumps(payload)}
        ]
    }

    resp = consumer_lambda.lambda_handler(event, None)
    assert resp["status"] == "processed"
    assert len(resp["results"]["failed"]) == 1
    assert patched_storage.items == []  # nada escrito

import pytest
from src.lambdas import consumer_lambda


def test_lambda_handler_missing_env(monkeypatch):
    # Elimina la variable de entorno
    monkeypatch.delenv("CATALOG_TABLE_NAME", raising=False)
    # Reinicia storage
    consumer_lambda.storage = None

    event = {"Records": []}
    with pytest.raises(RuntimeError) as excinfo:
        consumer_lambda.lambda_handler(event, None)

    assert "CATALOG_TABLE_NAME environment variable is required" in str(excinfo.value)

import json
import pytest
from src.lambdas import consumer_lambda
from src.lambdas.storage.base import StorageAdapter


class FailingStorageAdapter(StorageAdapter):
    def put_item(self, item: dict) -> None:
        raise Exception("Simulated DynamoDB failure")

def test_lambda_handler_storage_exception(monkeypatch):
    fake_storage = FailingStorageAdapter()
    monkeypatch.setattr(consumer_lambda, "storage", fake_storage)
    monkeypatch.setenv("CATALOG_TABLE_NAME", "fake-table")
    payload = {
        "kind": "book_request",
        "payload": {
            "title": "Some Book",
            "isbn": "1234567890",
            "requester_email": "user@example.com"
        }
    }
    event = {
        "Records": [
            {"messageId": "msg-321", "body": json.dumps(payload)}
        ]
    }

    resp = consumer_lambda.lambda_handler(event, None)
    assert resp["status"] == "processed"
    assert len(resp["results"]["failed"]) == 1
    assert resp["results"]["failed"][0]["id"] == "msg-321"
    assert "Simulated DynamoDB failure" in resp["results"]["failed"][0]["error"]
