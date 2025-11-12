# src/lambdas/validation/factory.py
from typing import ClassVar

from .base import PayloadValidator
from .book_validator import BookRequestValidator


class ValidatorFactory:
    """Centralized factory returning the right validator."""

    _registry: ClassVar[dict[str, PayloadValidator]] = {
        "book_request": BookRequestValidator(),
    }

    @staticmethod
    def get_validator(kind: str) -> PayloadValidator | None:
        return ValidatorFactory._registry.get(kind.lower())
