import json
import os
from typing import Any

from aws_lambda_typing.context import Context

from src.lambdas.enrichers.builder import build_enrichers_for_kind
from src.lambdas.facade.enrichment_facade import EnrichmentFacade
from src.lambdas.processors.book_processor import parse_record
from src.lambdas.storage.dynamo_adapter import DynamoDBAdapter
from src.lambdas.validation.factory import ValidatorFactory

# Lazy initialization
storage: DynamoDBAdapter | None = None
facade: EnrichmentFacade | None = None


def lambda_handler(event: dict[str, Any], context: Context | None) -> dict[str, Any]:
    global storage, facade
    print("EVENT RAW:", json.dumps(event))

    # Initialize storage
    if storage is None:
        table_name = os.getenv("CATALOG_TABLE_NAME")
        if not table_name:
            raise RuntimeError("CATALOG_TABLE_NAME environment variable is required")
        storage = DynamoDBAdapter(table_name)
        print(f"Initialized DynamoDBAdapter with table: {table_name}")

    # Initialize facade
    if facade is None:
        facade = EnrichmentFacade(
            validator_factory=ValidatorFactory,
            enrichers=build_enrichers_for_kind(),
            storage=storage,
        )
        print("Initialized EnrichmentFacade")

    results: dict[str, Any] = {"success": [], "failed": []}

    for record in event.get("Records", []):
        print("Processing record:", json.dumps(record))
        kind, payload, meta = parse_record(record)
        print("Parsed record:", {"kind": kind, "payload": payload, "meta": meta})

        # Only treat None as malformed (not empty dicts)
        if kind is None or payload is None:
            error_info = {
                **meta,
                "ok": False,
                "error": meta.get("error", "Malformed message"),
            }
            results["failed"].append(error_info)
            print("Failed to parse record:", error_info)
            continue

        # Always set 'id' for DynamoDB
        if payload.get("isbn"):
            payload["id"] = payload["isbn"]
            print(f"Using ISBN as id: {payload['id']}")
        else:
            payload["id"] = meta.get("id")
            print(f"Fallback id from meta: {payload['id']}")

        try:
            print("Calling facade.process with payload:", payload)
            res = facade.process(kind, payload, meta)
            print("Facade result:", res)

            if res.get("ok"):
                results["success"].append(res)
                print("Successfully persisted:", res)
            else:
                results["failed"].append(res)
                print("Failed to process:", res)
        except Exception as e:
            error_info = {**meta, "ok": False, "error": str(e)}
            results["failed"].append(error_info)
            print("Exception during processing:", error_info)

    print("Final results:", results)
    return {"status": "processed", "results": results}
