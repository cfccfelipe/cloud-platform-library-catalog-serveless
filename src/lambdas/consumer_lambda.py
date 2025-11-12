import os
from typing import Any

from aws_lambda_typing.context import Context

from src.lambdas.processors.book_processor import process_record
from src.lambdas.storage.dynamo_adapter import DynamoDBAdapter

# Storage se inicializa en el primer llamado
storage: DynamoDBAdapter | None = None


def lambda_handler(event: dict[str, Any], context: Context | None) -> dict[str, Any]:
    global storage

    # Inicializar storage solo una vez
    if storage is None:
        table_name = os.getenv("CATALOG_TABLE_NAME")
        if not table_name:
            raise RuntimeError("CATALOG_TABLE_NAME environment variable is required")
        storage = DynamoDBAdapter(table_name)

    results: dict[str, Any] = {"success": [], "failed": []}

    for record in event.get("Records", []):
        try:
            res = process_record(record, storage)
            if res.get("ok"):
                results["success"].append(res)
            else:
                results["failed"].append(res)
        except Exception as e:
            results["failed"].append({"id": record.get("messageId"), "error": str(e)})

    return {"status": "processed", "results": results}
