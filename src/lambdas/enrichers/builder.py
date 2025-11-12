from collections.abc import Callable
from typing import Any

# Import local enrichers
from src.lambdas.enrichers.common import add_request_hash, add_timestamp

# Import external enrichers
from src.lambdas.enrichers.external import enrich_with_openlibrary


def build_enrichers_for_kind() -> (
    dict[str, list[Callable[[dict[str, Any]], dict[str, Any]]]]
):
    """
    Central builder that returns the enrichers pipeline per kind.
    Each enricher is a callable that takes a payload dict and returns an enriched dict.
    """
    return {
        "book_request": [
            add_timestamp,
            add_request_hash,
            enrich_with_openlibrary,  # ✅ external API enricher
        ],
        # You can add other kinds here with their own enrichers
        # "user_signup": [add_timestamp, enrich_with_profile_api],
    }
