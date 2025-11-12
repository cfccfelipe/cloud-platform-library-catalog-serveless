import pytest
from src.lambdas.consumer_lambda import lambda_handler
from src.lambdas.storage.base import StorageAdapter


# ✅ FakeStorage hereda de StorageAdapter → compatible con type hints
class FakeStorage(StorageAdapter):
    def __init__(self):
        self.items = []

    def put_item(self, item: dict) -> None:
        self.items.append(item)


def test_lambda_success(monkeypatch):
    from src.lambdas import consumer_lambda

    # Patch storage and facade
    consumer_lambda.storage = FakeStorage()

    def fake_process(kind, payload, meta):
        return {"ok": True, "data": {**payload, "enriched": True}, **meta}

    class FakeFacade:
        def process(self, kind, payload, meta):
            return fake_process(kind, payload, meta)

    consumer_lambda.facade = FakeFacade()

    event = {
        "Records": [
            {
                "messageId": "1",
                "body": '{"kind":"book_request","payload":{"title":"T","isbn":"123","requester_email":"a@b.com"}}'
            }
        ]
    }

    res = lambda_handler(event, None)
    assert res["status"] == "processed"
    assert len(res["results"]["success"]) == 1
    assert res["results"]["success"][0]["data"]["enriched"] is True


def test_lambda_failed(monkeypatch):
    from src.lambdas import consumer_lambda

    consumer_lambda.storage = FakeStorage()

    class FakeFacade:
        def process(self, kind, payload, meta):
            return {"ok": False, "error": "boom", **meta}

    consumer_lambda.facade = FakeFacade()

    event = {
        "Records": [
            {"messageId": "2", "body": '{"kind":"book_request","payload":{}}'}
        ]
    }

    res = lambda_handler(event, None)
    assert len(res["results"]["failed"]) == 1
    assert res["results"]["failed"][0]["error"] == "boom"


def test_lambda_malformed_record(monkeypatch):
    from src.lambdas import consumer_lambda

    # Definir variable de entorno requerida
    monkeypatch.setenv("CATALOG_TABLE_NAME", "FakeTable")

    # Patch facade y storage para que no se inicialicen
    consumer_lambda.facade = None
    consumer_lambda.storage = None

    event = {
        "Records": [
            {"messageId": "bad1", "body": "not a json"}
        ]
    }

    res = lambda_handler(event, None)
    assert res["status"] == "processed"
    assert len(res["results"]["failed"]) == 1
    assert res["results"]["failed"][0]["error"] == "Invalid JSON"


def test_lambda_facade_exception(monkeypatch):
    from src.lambdas import consumer_lambda

    # Definir variable de entorno requerida
    monkeypatch.setenv("CATALOG_TABLE_NAME", "FakeTable")

    class ExplodingFacade:
        def process(self, kind, payload, meta):
            raise RuntimeError("boom")

    consumer_lambda.facade = ExplodingFacade()
    consumer_lambda.storage = None

    event = {
        "Records": [
            {"messageId": "ex1", "body": '{"kind":"book_request","payload":{}}'}
        ]
    }

    res = lambda_handler(event, None)
    assert res["status"] == "processed"
    assert len(res["results"]["failed"]) == 1
    assert "boom" in res["results"]["failed"][0]["error"]

def test_lambda_missing_env_var(monkeypatch):
    from src.lambdas import consumer_lambda

    # Aseguramos que la variable no esté definida
    monkeypatch.delenv("CATALOG_TABLE_NAME", raising=False)

    # Resetear storage y facade para forzar inicialización
    consumer_lambda.storage = None
    consumer_lambda.facade = None

    event = {"Records": []}

    with pytest.raises(RuntimeError) as excinfo:
        lambda_handler(event, None)

    assert "CATALOG_TABLE_NAME environment variable is required" in str(excinfo.value)
