import json
from src.lambdas.processors.book_processor import process_record
from src.lambdas.storage.base import StorageAdapter


class FakeStorageAdapter(StorageAdapter):
    def put_item(self, item: dict) -> None:
        pass  # no hace nada


def test_process_record_no_validator():
    record = {
        "messageId": "msg-999",
        "body": json.dumps({"kind": "unknown_kind", "payload": {"foo": "bar"}})
    }
    storage = FakeStorageAdapter()

    result = process_record(record, storage)
    assert result["id"] == "msg-999"
    assert "No validator for kind" in result["error"]
