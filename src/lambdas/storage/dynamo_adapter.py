from typing import Any

import boto3

from src.lambdas.storage.base import StorageAdapter


class DynamoDBAdapter(StorageAdapter):
    """Concrete adapter for DynamoDB persistence."""

    def __init__(self, table_name: str) -> None:
        dynamodb = boto3.resource("dynamodb")
        self.table = dynamodb.Table(table_name)

    def put_item(self, item: dict[str, Any]) -> None:
        self.table.put_item(Item=item)
