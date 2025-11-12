# src/lambdas/validation/book_validator.py
from typing import Any

from pydantic import BaseModel, EmailStr, Field, ValidationError

from .base import PayloadValidator


class BookRequestPayload(BaseModel):
    title: str = Field(..., min_length=1)  # ✅ no acepta string vacío
    isbn: str = Field(..., min_length=1)  # ✅ no acepta string vacío
    requester_email: EmailStr  # ✅ enforce valid email


class BookRequestValidator(PayloadValidator):
    def validate(
        self, payload: dict[str, Any]
    ) -> tuple[dict[str, Any] | None, list[dict[str, str]] | None]:
        """
        Validate the payload for a book request.
        Returns (validated_data, errors).
        """
        try:
            obj = BookRequestPayload.model_validate(payload)  # ✅ Pydantic v2
            return obj.model_dump(), None
        except ValidationError as exc:
            errors: list[dict[str, str]] = []
            for e in exc.errors():
                loc = e.get("loc")
                field = str(loc[0]) if loc and len(loc) > 0 else "unknown"
                msg = str(e.get("msg", "Invalid value"))
                errors.append({"field": field, "msg": msg})
            return None, errors
