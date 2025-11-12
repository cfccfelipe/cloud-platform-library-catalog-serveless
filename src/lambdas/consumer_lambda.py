import os
from typing import Any

from aws_lambda_typing.context import Context

from src.lambdas.enrichers.builder import build_enrichers_for_kind
from src.lambdas.facade.enrichment_facade import EnrichmentFacade
from src.lambdas.processors.book_processor import parse_record
from src.lambdas.storage.dynamo_adapter import DynamoDBAdapter
from src.lambdas.validation.factory import ValidatorFactory

# Lazy initialization: storage y facade se crean en el primer llamado
storage: DynamoDBAdapter | None = None
facade: EnrichmentFacade | None = None


def lambda_handler(event: dict[str, Any], context: Context | None) -> dict[str, Any]:
    """
    AWS Lambda handler for consuming SQS messages and persisting enriched records to DynamoDB.

    Responsibilities:
    - Initialize DynamoDB storage and Facade on the first invocation (lazy init).
    - Iterate over SQS records in the event (batch handling).
    - Parse each record (kind, payload, metadata).
    - Process payloads via Facade (validate, enrich, persist).
    - Collect results into success and failed lists.

    Args:
        event: Lambda event containing SQS Records.
        context: Lambda context object (unused here).

    Returns:
        dict with:
        - status: "processed"
        - results: {
            "success": [list of successfully processed records],
            "failed": [list of failed records with error info]
        }
    """
    global storage, facade

    if storage is None:
        table_name = os.getenv("CATALOG_TABLE_NAME")
        if not table_name:
            raise RuntimeError("CATALOG_TABLE_NAME environment variable is required")
        storage = DynamoDBAdapter(table_name)

    if facade is None:
        facade = EnrichmentFacade(
            validator_factory=ValidatorFactory,
            enrichers=build_enrichers_for_kind(),
            storage=storage,
        )

    results: dict[str, Any] = {"success": [], "failed": []}

    for record in event.get("Records", []):
        kind, payload, meta = parse_record(record)
        if kind is None or payload is None:
            results["failed"].append(
                {**meta, "ok": False, "error": meta.get("error", "Malformed message")}
            )
            continue

        try:
            res = facade.process(kind, payload, meta)
            if res.get("ok"):
                # Success: enriched record persisted to DynamoDB
                results["success"].append(res)
            else:
                results["failed"].append(res)
        except Exception as e:
            results["failed"].append({**meta, "ok": False, "error": str(e)})

    return {"status": "processed", "results": results}
