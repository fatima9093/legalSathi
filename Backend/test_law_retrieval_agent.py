"""
test_law_retrieval_agent.py
----------------------------
Standalone async test script for the Law Retrieval Agent.

Searches both local ChromaDB PDFs and official Pakistani government websites
for relevant legal content and prints formatted results.

Usage:
    python test_law_retrieval_agent.py
    python test_law_retrieval_agent.py --query "minimum wage Punjab 2019" --module labour_rights --limit 3
"""

from __future__ import annotations

import argparse
import asyncio
import logging
import os
import sys
import textwrap
from typing import Dict, List, Optional

# Disable ChromaDB telemetry before any imports that might trigger it.
os.environ.setdefault("ANONYMIZED_TELEMETRY", "false")

from law_retrieval_agent import LawRetrievalError, run_law_retrieval_agent

logging.basicConfig(
    level=logging.WARNING,
    format="%(levelname)s | %(name)s | %(message)s",
)
logger = logging.getLogger("test_law_retrieval_agent")

# ---------------------------------------------------------------------------
# Default sample queries exercising each of the four legal modules.
# ---------------------------------------------------------------------------
SAMPLE_QUERIES: List[Dict[str, str]] = [
    {
        "label": "Women Harassment",
        "query": "What is the procedure to file a harassment complaint under PAHAW 2010?",
        "module": "women_harassment",
    },
    {
        "label": "Labour Rights",
        "query": "What is the minimum wage for factory workers in Punjab 2019?",
        "module": "labour_rights",
    },
    {
        "label": "Cyber Law",
        "query": "What are the penalties for cyberstalking under the Prevention of Electronic Crimes Act?",
        "module": "cyber_law",
    },
    {
        "label": "Road Laws",
        "query": "What are the fines for running a red light in Pakistan?",
        "module": "road_laws",
    },
]

# ---------------------------------------------------------------------------
# Formatting helpers
# ---------------------------------------------------------------------------

SEPARATOR = "=" * 72
SUBSEP = "-" * 72


def _truncate(text: str, max_chars: int = 400) -> str:
    """Return ``text`` truncated to ``max_chars`` with a trailing ellipsis."""
    text = text.strip()
    if len(text) <= max_chars:
        return text
    return text[:max_chars].rstrip() + " …"


def _print_result(index: int, result: Dict[str, Optional[str]]) -> None:
    """Pretty-print a single retrieval result dict."""
    content = result.get("content") or "(no content)"
    source_url = result.get("source_url") or "(unknown source)"
    last_updated = result.get("last_updated") or "N/A"

    print(f"  Result #{index}")
    print(f"  Source:       {source_url}")
    print(f"  Last Updated: {last_updated}")
    print(f"  Content:")
    wrapped = textwrap.fill(
        _truncate(content),
        width=68,
        initial_indent="    ",
        subsequent_indent="    ",
    )
    print(wrapped)
    print()


async def _run_single_query(
    query: str,
    module: Optional[str],
    limit: int,
    label: str = "",
) -> None:
    """Execute one query against the law retrieval agent and print results.

    Args:
        query: Natural-language legal question.
        module: Optional ChromaDB module key to filter results.
        limit: Maximum number of results to return.
        label: Human-readable label for display purposes.
    """
    header = label if label else query
    print(SEPARATOR)
    print(f"  Query: {header}")
    if module:
        print(f"  Module filter: {module}")
    print(f"  Limit: {limit}")
    print(SUBSEP)

    try:
        results = await run_law_retrieval_agent(query=query, module=module, limit=limit)
    except LawRetrievalError as exc:
        print(f"  [ERROR] Retrieval failed: {exc}")
        print(SEPARATOR)
        print()
        return
    except Exception as exc:  # pragma: no cover - unexpected failures
        logger.exception("Unexpected error during retrieval: %s", exc)
        print(f"  [ERROR] Unexpected failure: {exc}")
        print(SEPARATOR)
        print()
        return

    if not results:
        print("  No relevant documents found for this query.")
        print(SEPARATOR)
        print()
        return

    print(f"  Found {len(results)} result(s):\n")
    for i, result in enumerate(results, start=1):
        _print_result(i, result)

    print(SEPARATOR)
    print()


async def run_all_samples(limit: int) -> None:
    """Run all built-in sample queries sequentially.

    Args:
        limit: Maximum number of results per query.
    """
    print()
    print(SEPARATOR)
    print("  Legal Sathi — Law Retrieval Agent Test")
    print("  Running all sample queries …")
    print(SEPARATOR)
    print()

    for sample in SAMPLE_QUERIES:
        await _run_single_query(
            query=sample["query"],
            module=sample.get("module"),
            limit=limit,
            label=sample["label"],
        )
        # Brief pause between queries to avoid hammering external services.
        await asyncio.sleep(0.5)


async def run_custom_query(query: str, module: Optional[str], limit: int) -> None:
    """Run a single user-supplied query.

    Args:
        query: Natural-language legal question.
        module: Optional ChromaDB module key.
        limit: Maximum number of results.
    """
    await _run_single_query(query=query, module=module, limit=limit)


# ---------------------------------------------------------------------------
# Entrypoint
# ---------------------------------------------------------------------------

def _parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description="Test the Legal Sathi Law Retrieval Agent.",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog=textwrap.dedent(
            """\
            Examples:
              # Run all built-in sample queries
              python test_law_retrieval_agent.py

              # Run a custom query with module filter
              python test_law_retrieval_agent.py \\
                  --query "online harassment punishment" \\
                  --module cyber_law \\
                  --limit 3
            """
        ),
    )
    parser.add_argument(
        "--query",
        type=str,
        default=None,
        help=(
            "Custom legal question to test. "
            "If omitted, all built-in sample queries are run."
        ),
    )
    parser.add_argument(
        "--module",
        type=str,
        default=None,
        choices=["women_harassment", "labour_rights", "cyber_law", "road_laws"],
        help="Restrict ChromaDB results to one legal module.",
    )
    parser.add_argument(
        "--limit",
        type=int,
        default=3,
        help="Maximum number of results to return per query (default: 3).",
    )
    return parser.parse_args()


async def _main() -> None:
    args = _parse_args()

    if args.limit <= 0:
        print("[ERROR] --limit must be a positive integer.", file=sys.stderr)
        sys.exit(1)

    if args.query:
        await run_custom_query(
            query=args.query.strip(),
            module=args.module,
            limit=args.limit,
        )
    else:
        await run_all_samples(limit=args.limit)


if __name__ == "__main__":
    asyncio.run(_main())
