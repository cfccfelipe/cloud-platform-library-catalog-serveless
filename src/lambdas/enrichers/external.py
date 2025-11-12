from typing import Any

import requests


def enrich_with_openlibrary(data: dict[str, Any]) -> dict[str, Any]:
    """
    Enricher that calls OpenLibrary by ISBN and adds metadata.
    """
    isbn = data.get("isbn")
    if not isbn:
        return {**data, "external_info": None}

    try:
        resp = requests.get(f"https://openlibrary.org/isbn/{isbn}.json", timeout=5)
        if resp.status_code == 200:
            book_info = resp.json()
            return {
                **data,
                "external_info": {
                    "title": book_info.get("title"),
                    "publish_date": book_info.get("publish_date"),
                    "authors": book_info.get("authors"),
                },
            }
        else:
            return {**data, "external_info": None}
    except Exception as e:
        return {**data, "external_info_error": str(e)}
