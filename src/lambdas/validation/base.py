# src/lambdas/validation/base.py
from abc import ABC, abstractmethod
from typing import Any


class PayloadValidator(ABC):
    """Abstract product: defines the validation contract."""

    @abstractmethod
    def validate(
        self, payload: dict[str, Any]
    ) -> tuple[dict[str, Any] | None, list[dict[str, str]] | None]:
        """Validate payload and return (validated_data, errors)."""
