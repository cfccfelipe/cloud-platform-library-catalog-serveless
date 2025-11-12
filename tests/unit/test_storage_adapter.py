import pytest
from src.lambdas.storage.dynamo_adapter import DynamoDBAdapter


class FakeTable:
    """Fake DynamoDB Table to capture put_item calls."""
    def __init__(self, name: str):
        self.name = name
        self.items = []

    def put_item(self, Item: dict):
        self.items.append(Item)
        return {"ResponseMetadata": {"HTTPStatusCode": 200}}


class FakeDynamoResource:
    """Fake boto3 DynamoDB resource."""
    def __init__(self):
        self.tables = {}

    def Table(self, name: str) -> FakeTable:
        if name not in self.tables:
            self.tables[name] = FakeTable(name)
        return self.tables[name]


def test_dynamo_adapter_init_and_put(monkeypatch):
    # Patch boto3.resource to return our fake resource
    fake_resource = FakeDynamoResource()
    monkeypatch.setattr("boto3.resource", lambda service: fake_resource)

    adapter = DynamoDBAdapter("test-table")

    # Verifica que la tabla se inicializó correctamente
    assert isinstance(adapter.table, FakeTable)
    assert adapter.table.name == "test-table"

    # Inserta un item
    item = {"id": "123", "title": "Clean Architecture"}
    adapter.put_item(item)

    # Verifica que el item fue capturado
    assert adapter.table.items[0]["title"] == "Clean Architecture"
    assert adapter.table.items[0]["id"] == "123"
