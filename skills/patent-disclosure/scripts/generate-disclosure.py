#!/usr/bin/env python3
"""
Patent Disclosure Generator

Generates patent disclosure JSON from innovation data.
This script is called by Claude Code to ensure files are actually written to disk.

Usage:
    python generate-disclosure.py <innovation-id> <output-path> [--input-json <path>]

The script reads innovation data from stdin (JSON format) and writes the disclosure to the output path.
"""

import json
import sys
import os
from datetime import date
from pathlib import Path


def create_disclosure_structure(innovation_data: dict) -> dict:
    """Create the disclosure JSON structure from innovation data."""

    today = date.today().isoformat()
    innovation_id = innovation_data.get('id', 'INV-001')

    disclosure = {
        "metadata": {
            "title": innovation_data.get('title', ''),
            "title_zh": innovation_data.get('title_zh', ''),
            "field_of_invention": innovation_data.get('field_of_invention', []),
            "application_number": innovation_data.get('application_number', f'VS-{innovation_id}-{today[:4]}'),
            "priority_date": "To be established upon provisional filing",
            "inventors": innovation_data.get('inventors', ['Transformation AI Team']),
            "assignee": innovation_data.get('assignee', 'ViewSonic Corporation'),
            "generated_date": today,
            "innovation_id": innovation_id
        },
        "abstract": innovation_data.get('abstract', {
            "en": "",
            "zh_tw": ""
        }),
        "problem_statement": {
            "background": innovation_data.get('problem_statement', {}).get('background', [])
        },
        "summary": {
            "overview": innovation_data.get('summary', {}).get('overview', []),
            "key_innovations": innovation_data.get('summary', {}).get('key_innovations', [])
        },
        "detailed_description": innovation_data.get('detailed_description', {
            "system_architecture": "",
            "components": []
        }),
        "claims": innovation_data.get('claims', []),
        "drawings": innovation_data.get('drawings', []),
        "prior_art": innovation_data.get('prior_art', {
            "reviewed_systems": [],
            "differentiation": ""
        })
    }

    return disclosure


def main():
    if len(sys.argv) < 3:
        print("Usage: python generate-disclosure.py <innovation-id> <output-path> [--stdin]", file=sys.stderr)
        print("\nReads innovation data from stdin as JSON.", file=sys.stderr)
        sys.exit(1)

    innovation_id = sys.argv[1]
    output_path = sys.argv[2]

    # Ensure output directory exists
    output_dir = Path(output_path).parent
    output_dir.mkdir(parents=True, exist_ok=True)

    # Check if we should read from stdin or from a file
    if '--input-json' in sys.argv:
        input_idx = sys.argv.index('--input-json')
        if input_idx + 1 < len(sys.argv):
            input_path = sys.argv[input_idx + 1]
            with open(input_path, 'r', encoding='utf-8') as f:
                innovation_data = json.load(f)
        else:
            print("Error: --input-json requires a path", file=sys.stderr)
            sys.exit(1)
    elif not sys.stdin.isatty():
        # Read from stdin
        try:
            input_text = sys.stdin.read()
            innovation_data = json.loads(input_text)
        except json.JSONDecodeError as e:
            print(f"Error parsing JSON from stdin: {e}", file=sys.stderr)
            sys.exit(1)
    else:
        # Create minimal structure with just the ID
        innovation_data = {"id": innovation_id}

    # Ensure innovation ID is set
    innovation_data['id'] = innovation_id

    # Generate disclosure structure
    disclosure = create_disclosure_structure(innovation_data)

    # Validate drawings — warn if missing (most commonly skipped section)
    drawings = disclosure.get('drawings', innovation_data.get('drawings', []))
    if not drawings:
        print("\033[1;33mWARNING: No 'drawings' field found — PDF will lack diagrams.\033[0m", file=sys.stderr)
        print("Add a 'drawings' array with 'mermaid_code' fields to include architecture diagrams in the PDF.", file=sys.stderr)
    else:
        # Ensure drawings are in the disclosure
        if 'drawings' not in disclosure:
            disclosure['drawings'] = drawings
        missing_mermaid = [d for d in drawings if not d.get('mermaid_code')]
        if missing_mermaid:
            figs = ', '.join(f"FIG. {d.get('figure_number', '?')}" for d in missing_mermaid)
            print(f"\033[1;33mWARNING: Drawings {figs} lack 'mermaid_code' — will render as text only.\033[0m", file=sys.stderr)
        else:
            print(f"\033[0;32m✓ {len(drawings)} drawings with mermaid_code found — diagrams will render in PDF.\033[0m")

    # Write to file
    with open(output_path, 'w', encoding='utf-8') as f:
        json.dump(disclosure, f, ensure_ascii=False, indent=2)

    print(f"Disclosure written to: {output_path}")

    # Return the path for further processing
    return output_path


if __name__ == "__main__":
    main()
