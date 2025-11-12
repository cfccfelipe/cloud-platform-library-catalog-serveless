import pytest
import requests
from src.lambdas.enrichers.external import enrich_with_openlibrary


class DummyResponse:
    def __init__(self, status_code=200, json_data=None):
        self.status_code = status_code
        self._json_data = json_data or {}

    def json(self):
        return self._json_data


def test_enrich_with_openlibrary_success(monkeypatch):
    # Mock requests.get to return a fake book record
    def fake_get(url, timeout=5):
        return DummyResponse(
            200,
            {
                "title": "Matilda",
                "publish_date": "1988",
                "authors": [{"key": "/authors/OL34184A"}],
            },
        )

    monkeypatch.setattr(requests, "get", fake_get)

    data = {"isbn": "9780140328721", "title": "Matilda"}
    result = enrich_with_openlibrary(data)

    assert "external_info" in result
    assert result["external_info"]["title"] == "Matilda"
    assert result["external_info"]["publish_date"] == "1988"
    assert result["external_info"]["authors"][0]["key"] == "/authors/OL34184A"


def test_enrich_with_openlibrary_no_isbn():
    data = {"title": "Book without ISBN"}
    result = enrich_with_openlibrary(data)

    assert "external_info" in result
    assert result["external_info"] is None


def test_enrich_with_openlibrary_http_error(monkeypatch):
    def fake_get(url, timeout=5):
        return DummyResponse(status_code=404)

    monkeypatch.setattr(requests, "get", fake_get)

    data = {"isbn": "0000000000"}
    result = enrich_with_openlibrary(data)

    assert result["external_info"] is None


def test_enrich_with_openlibrary_exception(monkeypatch):
    def fake_get(url, timeout=5):
        raise requests.RequestException("network down")

    monkeypatch.setattr(requests, "get", fake_get)

    data = {"isbn": "9780140328721"}
    result = enrich_with_openlibrary(data)

    assert "external_info_error" in result
    assert "network down" in result["external_info_error"]
