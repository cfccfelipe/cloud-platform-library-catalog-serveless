# tests/unit/test_factory.py
from src.lambdas.validation.factory import ValidatorFactory

def test_factory_returns_book_validator():
    validator = ValidatorFactory.get_validator("book_request")
    assert validator is not None
    payload = {
        "title": "Domain-Driven Design",
        "isbn": "9780321125217",
        "requester_email": "ddd@example.com"
    }
    validated, errors = validator.validate(payload)
    assert errors is None
    assert validated is not None
    assert validated["title"] == "Domain-Driven Design"


def test_factory_invalid_kind():
    validator = ValidatorFactory.get_validator("unknown_kind")
    assert validator is None

def test_wrong_types():
    validator = ValidatorFactory.get_validator("book_request")
    assert validator is not None
    payload = {"title": 123, "isbn": 456, "requester_email": 789}
    validated, errors = validator.validate(payload)
    assert validated is None
    assert errors is not None
    assert any(e["field"] == "title" for e in errors)
    assert any(e["field"] == "isbn" for e in errors)
    assert any(e["field"] == "requester_email" for e in errors)

def test_empty_fields():
    validator = ValidatorFactory.get_validator("book_request")
    assert validator is not None
    payload = {"title": "", "isbn": "", "requester_email": ""}
    validated, errors = validator.validate(payload)
    assert validated is None
    assert errors is not None
    fields = [e["field"] for e in errors]
    assert "title" in fields
    assert "isbn" in fields
    assert "requester_email" in fields
