# tests/unit/test_book_request_validator.py
import pytest
from src.lambdas.validation.book_validator import BookRequestValidator

validator = BookRequestValidator()

def test_valid_payload():
    payload = {
        "title": "Clean Code",
        "isbn": "9780132350884",
        "requester_email": "user@example.com"
    }
    validated, errors = validator.validate(payload)
    assert errors is None
    assert validated is not None
    assert validated["title"] == "Clean Code"
    assert validated["isbn"] == "9780132350884"
    assert validated["requester_email"] == "user@example.com"

def test_missing_fields():
    payload = {"title": "Clean Code"}  # faltan isbn y requester_email
    validated, errors = validator.validate(payload)
    assert validated is None
    assert errors is not None
    fields = [e["field"] for e in errors]
    assert "isbn" in fields
    assert "requester_email" in fields

def test_invalid_email():
    payload = {
        "title": "Clean Code",
        "isbn": "9780132350884",
        "requester_email": "not-an-email"
    }
    validated, errors = validator.validate(payload)
    assert validated is None
    assert errors is not None
    assert any(e["field"] == "requester_email" for e in errors)

