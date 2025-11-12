import pytest
from typing import Any
from src.lambdas.facade.enrichment_facade import EnrichmentFacade
from src.lambdas.validation.factory import ValidatorFactory
from src.lambdas.storage.base import StorageAdapter


class FakeValidator:
    def __init__(self, should_fail: bool = False):
        self.should_fail = should_fail

    def validate(self, payload: dict[str, Any]):
        if self.should_fail:
            return None, {"error": "invalid"}
        return payload, None


# ✅ Hereda de ValidatorFactory → compatible con type hints
class FakeValidatorFactory(ValidatorFactory):
    @staticmethod
    def get_validator(kind: str):
        if kind == "book_request":
            return FakeValidator()
        return None


# ✅ Hereda de StorageAdapter → compatible con type hints
class FakeStorage(StorageAdapter):
    def __init__(self, should_fail: bool = False):
        self.items: list[dict[str, Any]] = []
        self.should_fail = should_fail

    def put_item(self, item: dict[str, Any]) -> None:
        if self.should_fail:
            raise RuntimeError("DB down")
        self.items.append(item)


def test_facade_success():
    storage = FakeStorage()
    facade = EnrichmentFacade(
        validator_factory=FakeValidatorFactory,
        enrichers={"book_request": [lambda d: {**d, "extra": "ok"}]},
        storage=storage,
    )

    meta = {"id": "123"}
    payload = {"title": "Book", "isbn": "111", "requester_email": "a@b.com"}
    res = facade.process("book_request", payload, meta)

    assert res["ok"] is True
    assert "extra" in res["data"]
    assert storage.items[0]["extra"] == "ok"


def test_facade_no_validator():
    class EmptyValidatorFactory(ValidatorFactory):
        @staticmethod
        def get_validator(kind: str):
            return None

    storage = FakeStorage()
    facade = EnrichmentFacade(
        validator_factory=EmptyValidatorFactory,
        enrichers={},
        storage=storage,
    )

    res = facade.process("unknown_kind", {}, {"id": "123"})
    assert res["ok"] is False
    assert "No validator" in res["error"]
    assert storage.items == []


def test_facade_validation_error():
    class BadValidatorFactory(ValidatorFactory):
        @staticmethod
        def get_validator(kind: str):
            return FakeValidator(should_fail=True)

    storage = FakeStorage()
    facade = EnrichmentFacade(
        validator_factory=BadValidatorFactory,
        enrichers={},
        storage=storage,
    )

    res = facade.process("book_request", {}, {"id": "123"})
    assert res["ok"] is False
    assert res["error"] == "ValidationError"
    assert storage.items == []


def test_facade_enricher_exception():
    storage = FakeStorage()

    def bad_enricher(data: dict[str, Any]) -> dict[str, Any]:
        raise ValueError("bad enricher")

    facade = EnrichmentFacade(
        validator_factory=FakeValidatorFactory,
        enrichers={"book_request": [bad_enricher]},
        storage=storage,
    )

    meta = {"id": "456"}
    payload = {"title": "Book", "isbn": "111", "requester_email": "a@b.com"}
    res = facade.process("book_request", payload, meta)

    assert res["ok"] is False
    assert "Enrichment failed" in res["error"]
    assert storage.items == []


def test_facade_persistence_exception():
    storage = FakeStorage(should_fail=True)
    facade = EnrichmentFacade(
        validator_factory=FakeValidatorFactory,
        enrichers={},
        storage=storage,
    )

    meta = {"id": "789"}
    payload = {"title": "Book", "isbn": "111", "requester_email": "a@b.com"}
    res = facade.process("book_request", payload, meta)

    assert res["ok"] is False
    assert "Persistence failed" in res["error"]
    assert storage.items == []
