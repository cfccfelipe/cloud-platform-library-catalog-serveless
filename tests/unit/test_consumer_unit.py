import pytest
from src.lambdas.processors.book_processor import process_record
from src.lambdas.storage.base import StorageAdapter

# Fake storage adapter for unit tests
class FakeStorageAdapter(StorageAdapter):
    def __init__(self):
        self.items = []

    def put_item(self, item: dict) -> None:
        self.items.append(item)


def test_process_record_valid_payload():
    record = {
        "messageId": "123",
        "body": '{"kind":"book_request","payload":{"title":"1984","isbn":"9780451524935","requester_email":"reader@example.com"}}'
    }
    storage = FakeStorageAdapter()

    result = process_record(record, storage)

    assert result["ok"] is True
    assert result["id"] == "req-123"
    assert storage.items[0]["title"] == "1984"


def test_process_record_invalid_payload():
    record = {
        "messageId": "456",
        "body": '{"kind":"book_request","payload":{"title":"","isbn":"","requester_email":"not-an-email"}}'
    }
    storage = FakeStorageAdapter()

    result = process_record(record, storage)

    assert "error" in result
    assert result["id"] == "456"
    assert storage.items == []  # no writes
