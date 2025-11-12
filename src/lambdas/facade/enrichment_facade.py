import json
from collections.abc import Callable
from typing import Any

from src.lambdas.storage.base import StorageAdapter
from src.lambdas.validation.factory import ValidatorFactory


class EnrichmentFacade:
    """
    Facade to orchestrate validation, enrichment, and persistence of SQS message payloads.

    Responsibilities:
    - Retrieve the appropriate validator for the given kind.
    - Validate the payload and handle validation errors.
    - Apply enrichment (e.g., timestamps, hashes, external API calls).
    - Persist the enriched record using the storage adapter.
    """

    def __init__(
        self,
        validator_factory: type[ValidatorFactory],
        enrichers: dict[str, list[Callable[[dict[str, Any]], dict[str, Any]]]],
        storage: StorageAdapter,
    ) -> None:
        self.validator_factory = validator_factory
        self.enrichers = enrichers
        self.storage = storage

    def process(
        self, kind: str, payload: dict[str, Any], meta: dict[str, Any]
    ) -> dict[str, Any]:
        print(f"[Facade] Processing kind='{kind}' with payload: {json.dumps(payload)}")

        validator = self.validator_factory.get_validator(kind)
        if validator is None:
            print(f"[Facade] No validator found for kind '{kind}'")
            return {"ok": False, "error": f"No validator for kind '{kind}'", **meta}

        validated, errors = validator.validate(payload)
        if errors:
            print(f"[Facade] Validation errors: {errors}")
            return {"ok": False, "error": "ValidationError", "details": errors, **meta}

        # Start with validated payload
        data: dict[str, Any] = validated or {}
        print(f"[Facade] Validated payload: {json.dumps(data)}")

        # Apply enrichers sequentially
        for enricher in self.enrichers.get(kind, []):
            try:
                print(f"[Facade] Applying enricher: {enricher.__name__}")
                data = enricher(data)
                print(
                    f"[Facade] Payload after enricher '{enricher.__name__}': {json.dumps(data)}"
                )
            except Exception as e:
                print(f"[Facade] Enrichment failed: {e!s}")
                return {"ok": False, "error": f"Enrichment failed: {e!s}", **meta}

        # Ensure 'id' exists before persisting
        if "id" not in data or not data.get("id"):
            data["id"] = data.get("isbn") or meta.get("id")
            print(f"[Facade] Injected id into item: {data['id']}")

        # Persist enriched record
        try:
            print(f"[Facade] Persisting item to storage: {json.dumps(data)}")
            self.storage.put_item(data)
            print("[Facade] Item persisted successfully")
        except Exception as e:
            print(f"[Facade] Persistence failed: {e!s}")
            return {"ok": False, "error": f"Persistence failed: {e!s}", **meta}

        return {"ok": True, "data": data, **meta}
