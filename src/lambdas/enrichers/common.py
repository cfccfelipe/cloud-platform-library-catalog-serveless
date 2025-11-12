# src/lambdas/enrichers/common.py
import hashlib
import time


def add_timestamp(data: dict) -> dict:
    return {**data, "ts": int(time.time())}


def add_request_hash(data: dict) -> dict:
    base = f"{data.get('isbn','')}|{data.get('title','')}"
    return {**data, "req_hash": hashlib.sha256(base.encode()).hexdigest()}


def build_enrichers_for_kind() -> dict[str, list]:
    return {
        "book_request": [add_timestamp, add_request_hash],
    }
