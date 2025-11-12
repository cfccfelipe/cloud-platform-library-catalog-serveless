# src/lambdas/facade/enrichment_facade.py
from collections.abc import Callable
from typing import Any

from src.lambdas.storage.base import StorageAdapter
from src.lambdas.validation.factory import ValidatorFactory


class EnrichmentFacade:
    """
    Facade to orchestrate validation, enrichment, and of SQS message payloads.

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
        """
        Initialize the facade.

        Args:
            validator_factory: Factory class to retrieve validators by kind.
            enrichers: Mapping of kind → list of enrichment functions.
            storage: Storage adapter implementation (e.g., DynamoDBAdapter).
        """
        self.validator_factory = validator_factory
        self.enrichers = enrichers
        self.storage = storage

    def process(
        self, kind: str, payload: dict[str, Any], meta: dict[str, Any]
    ) -> dict[str, Any]:
        """
        Process a single message payload.

        Steps:
        1. Retrieve validator for the given kind.
        2. Validate the payload.
        3. Apply enrichers sequentially.
        4. Persist the enriched record to storage.

        Args:
            kind: The type of payload (e.g., "book_request").
            payload: The raw payload dictionary.
            meta: Metadata such as messageId.

        Returns:
            dict containing:
            - ok: bool indicating success/failure.
            - data: enriched payload if successful.
            - error/details: error information if failed.
            - metadata fields (e.g., id).
        """
        validator = self.validator_factory.get_validator(kind)
        if validator is None:
            return {"ok": False, "error": f"No validator for kind '{kind}'", **meta}

        validated, errors = validator.validate(payload)
        if errors:
            return {"ok": False, "error": "ValidationError", "details": errors, **meta}

        # Start with validated payload
        data: dict[str, Any] = validated or {}

        # Apply enrichers sequentially
        for enricher in self.enrichers.get(kind, []):
            try:
                data = enricher(data)
            except Exception as e:
                return {"ok": False, "error": f"Enrichment failed: {e!s}", **meta}

        # Persist enriched record
        try:
            self.storage.put_item(data)
        except Exception as e:
            return {"ok": False, "error": f"Persistence failed: {e!s}", **meta}

        return {"ok": True, "data": data, **meta}
