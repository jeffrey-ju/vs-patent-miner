#!/usr/bin/env python3
"""
Patent Mining — Scan Results Saver

Saves innovation scan results to a JSON file.
This script is called by Claude Code to ensure files are actually written to disk.

Usage:
    echo '<json>' | python save-scan-results.py <output-path>

The script reads scan results from stdin (JSON format) and writes to the output path.
"""

import json
import sys
from datetime import date
from pathlib import Path


def validate_scan_results(data: dict) -> list[str]:
    """Validate scan results and return list of warnings."""
    warnings = []

    # Check required top-level fields
    if "scan_metadata" not in data:
        warnings.append("Missing 'scan_metadata' field")
    if "innovations" not in data:
        warnings.append("Missing 'innovations' field")
    elif not isinstance(data["innovations"], list):
        warnings.append("'innovations' must be an array")
    elif len(data["innovations"]) == 0:
        warnings.append("No innovations found in scan results")

    # Validate each innovation
    for i, inv in enumerate(data.get("innovations", [])):
        inv_id = inv.get("id", f"index-{i}")
        required = ["id", "title", "category", "novelty_score", "summary"]
        for field in required:
            if field not in inv:
                warnings.append(f"Innovation {inv_id}: missing '{field}' field")

        # Validate novelty_score range
        score = inv.get("novelty_score")
        if score is not None and (not isinstance(score, (int, float)) or score < 0 or score > 100):
            warnings.append(f"Innovation {inv_id}: novelty_score must be 0-100")

        # Check for source_files
        if not inv.get("source_files"):
            warnings.append(f"Innovation {inv_id}: no source_files listed")

    return warnings


def main():
    if len(sys.argv) < 2:
        print("Usage: echo '<json>' | python save-scan-results.py <output-path>", file=sys.stderr)
        print("\nReads scan results from stdin as JSON.", file=sys.stderr)
        sys.exit(1)

    output_path = sys.argv[1]

    # Ensure output directory exists
    output_dir = Path(output_path).parent
    output_dir.mkdir(parents=True, exist_ok=True)

    # Read from stdin
    if sys.stdin.isatty():
        print("Error: No input provided. Pipe JSON to stdin.", file=sys.stderr)
        sys.exit(1)

    try:
        input_text = sys.stdin.read()
        data = json.loads(input_text)
    except json.JSONDecodeError as e:
        print(f"Error parsing JSON from stdin: {e}", file=sys.stderr)
        sys.exit(1)

    # Add/update metadata
    if "scan_metadata" not in data:
        data["scan_metadata"] = {}
    data["scan_metadata"]["saved_date"] = date.today().isoformat()

    # Validate and warn
    warnings = validate_scan_results(data)
    if warnings:
        print("\033[1;33mWarnings:\033[0m", file=sys.stderr)
        for w in warnings:
            print(f"  • {w}", file=sys.stderr)

    # Write to file
    with open(output_path, 'w', encoding='utf-8') as f:
        json.dump(data, f, ensure_ascii=False, indent=2)

    innovation_count = len(data.get("innovations", []))
    print(f"\033[0;32m✓ Scan results saved: {output_path}\033[0m")
    print(f"  Innovations found: {innovation_count}")

    # Summary of innovations
    if innovation_count > 0:
        print("\n  Summary:")
        for inv in data["innovations"]:
            score = inv.get("novelty_score", "?")
            status = inv.get("status", "candidate")
            print(f"    {inv.get('id', '?')}: {inv.get('title', 'Untitled')} (score: {score}, {status})")

    return output_path


if __name__ == "__main__":
    main()
