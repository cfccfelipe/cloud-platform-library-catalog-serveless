from abc import ABC, abstractmethod
from typing import Any


class StorageAdapter(ABC):
    """Abstract adapter for persistence layer."""

    @abstractmethod
    def put_item(self, item: dict[str, Any]) -> None:
        """Persist an item into storage."""
