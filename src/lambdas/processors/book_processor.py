import json
from typing import Any


def parse_record(
    record: dict[str, Any],
) -> tuple[str | None, dict[str, Any] | None, dict[str, Any]]:
    """
    Parse an SQS record into kind, payload, and metadata.

    Args:
        record: Raw SQS record containing 'messageId' and 'body'.

    Returns:
        A tuple of (kind, payload, meta):
        - kind: str or None if missing.
        - payload: dict or None if invalid.
        - meta: dict with messageId and optional error.
    """
    meta = {"id": record.get("messageId")}
    try:
        body = json.loads(record.get("body", "{}"))
        return body.get("kind"), body.get("payload"), meta
    except json.JSONDecodeError:
        return None, None, {**meta, "error": "Invalid JSON"}
