import json
from datetime import UTC, datetime
from typing import Any

from src.lambdas.storage.base import StorageAdapter
from src.lambdas.validation.factory import ValidatorFactory


def process_record(record: dict, storage: StorageAdapter) -> dict[str, Any]:
    """
    Process a single SQS record:
    - Extract payload
    - Validate using factory
    - Persist via storage adapter
    """
    body = json.loads(record["body"])
    kind = body.get("kind", "").lower()
    payload = body.get("payload", {})

    validator = ValidatorFactory.get_validator(kind)
    if not validator:
        return {
            "id": record.get("messageId"),
            "error": f"No validator for kind '{kind}'",
        }

    validated, errors = validator.validate(payload)
    if validated is None:
        return {"id": record.get("messageId"), "error": errors}

    item = {
        "id": f"req-{record['messageId']}",
        "title": validated["title"],
        "isbn": validated["isbn"],
        "requester_email": validated["requester_email"],
        "processed_at": datetime.now(UTC).isoformat(),
    }

    storage.put_item(item)
    return {"ok": True, "id": item["id"]}
