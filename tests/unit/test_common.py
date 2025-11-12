import hashlib
import time
import pytest

from src.lambdas.enrichers.common import add_timestamp, add_request_hash


def test_add_timestamp(monkeypatch):
    # Mock time.time para que sea determinista
    monkeypatch.setattr(time, "time", lambda: 1234567890)

    data = {"title": "Book"}
    result = add_timestamp(data)

    assert "ts" in result
    assert result["ts"] == 1234567890
    # Verifica que los demás campos se mantienen
    assert result["title"] == "Book"


def test_add_request_hash_with_values():
    data = {"isbn": "111", "title": "Book"}
    result = add_request_hash(data)

    expected_base = "111|Book"
    expected_hash = hashlib.sha256(expected_base.encode()).hexdigest()

    assert "req_hash" in result
    assert result["req_hash"] == expected_hash
    # Verifica que los demás campos se mantienen
    assert result["isbn"] == "111"
    assert result["title"] == "Book"


def test_add_request_hash_with_missing_values():
    # Caso donde faltan isbn y title
    data = {}
    result = add_request_hash(data)

    expected_base = "|"
    expected_hash = hashlib.sha256(expected_base.encode()).hexdigest()

    assert result["req_hash"] == expected_hash
    # No debe añadir isbn ni title si no estaban
    assert "isbn" not in result
    assert "title" not in result
