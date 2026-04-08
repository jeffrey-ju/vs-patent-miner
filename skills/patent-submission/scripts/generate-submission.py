#!/usr/bin/env python3
"""
Patent Submission Generator

Generates patent submission JSON and PPTX from disclosure data.
This script is called by Claude Code to ensure files are actually written to disk.

Usage:
    python generate-submission.py <innovation-id> <output-path> [--from-disclosure <path>]

The script reads disclosure data from stdin or file and writes the submission JSON and PPTX.
"""

import json
import sys
import os
from datetime import date
from pathlib import Path


def create_submission_structure(disclosure_data: dict) -> dict:
    """Create the submission JSON structure from disclosure data."""

    metadata = disclosure_data.get('metadata', {})
    today = date.today().isoformat()

    submission = {
        "metadata": {
            "title_zh": metadata.get('title_zh', metadata.get('title', '')),
            "title_en": metadata.get('title', ''),
            "patent_id": metadata.get('application_number', ''),
            "date": today,
            "inventors": metadata.get('inventors', []),
            "assignee": metadata.get('assignee', 'ViewSonic Corporation')
        },
        "slides": []
    }

    # Slide 1: Title
    submission["slides"].append({
        "slide_number": 1,
        "type": "title",
        "content": {
            "title_zh": metadata.get('title_zh', metadata.get('title', '')),
            "title_en": metadata.get('title', ''),
            "subtitle": "Patent Disclosure",
            "application_number": metadata.get('application_number', ''),
            "date": today
        }
    })

    # Slide 2: Problem Statement
    problem = disclosure_data.get('problem_statement', {})
    background = problem.get('background', [])
    submission["slides"].append({
        "slide_number": 2,
        "type": "problem",
        "title": "本發明要解決的問題",
        "content": {
            "bullets": background if isinstance(background, list) else [background]
        }
    })

    # Slide 3: Solution
    summary = disclosure_data.get('summary', {})
    overview = summary.get('overview', [])
    key_innovations = summary.get('key_innovations', [])
    submission["slides"].append({
        "slide_number": 3,
        "type": "solution",
        "title": "本發明提出的解決方案",
        "content": {
            "overview": overview[0] if overview else "",
            "bullets": key_innovations if key_innovations else overview[1:] if len(overview) > 1 else []
        }
    })

    # Slide 4: Algorithm/Architecture
    detailed = disclosure_data.get('detailed_description', {})
    components = detailed.get('components', [])
    architecture = detailed.get('system_architecture', '')

    algo_bullets = []
    for comp in components[:4]:  # Limit to 4 components
        if isinstance(comp, dict):
            name = comp.get('name', '')
            weight = comp.get('weight', '')
            desc = comp.get('description', '')[:100]  # Truncate
            if weight:
                algo_bullets.append(f"{name} (權重 {int(weight*100)}%): {desc}")
            else:
                algo_bullets.append(f"{name}: {desc}")
        else:
            algo_bullets.append(str(comp))

    submission["slides"].append({
        "slide_number": 4,
        "type": "algorithm",
        "title": "演算法流程圖",
        "content": {
            "bullets": algo_bullets,
            "diagram_description": architecture[:200] if architecture else "系統架構圖"
        }
    })

    # Slide 5: Advantages/Features
    # Extract advantages from detailed description or summary
    advantages = []
    if key_innovations:
        advantages = key_innovations[:5]
    elif components:
        advantages = [f"{c.get('name', '')}: {c.get('description', '')[:80]}"
                     for c in components[:5] if isinstance(c, dict)]

    submission["slides"].append({
        "slide_number": 5,
        "type": "advantages",
        "title": "本發明的技術優勢",
        "content": {
            "bullets": advantages
        }
    })

    # Slide 6: Claims Summary
    claims = disclosure_data.get('claims', [])
    claims_summary = []
    for claim in claims[:5]:  # Limit to 5 claims
        if isinstance(claim, dict):
            claim_num = claim.get('claim_number', '')
            claim_type = claim.get('claim_type', '')
            claim_text = claim.get('text', '')[:150]  # Truncate
            claims_summary.append(f"Claim {claim_num} ({claim_type}): {claim_text}")
        else:
            claims_summary.append(str(claim))

    submission["slides"].append({
        "slide_number": 6,
        "type": "appendix",
        "title": "Appendix: Claims 摘要",
        "content": {
            "claims_summary": claims_summary
        }
    })

    # Slide 7: Closing
    submission["slides"].append({
        "slide_number": 7,
        "type": "closing",
        "content": {
            "contact": {
                "team": ", ".join(metadata.get('inventors', [])),
                "company": metadata.get('assignee', '')
            }
        }
    })

    return submission


def generate_pptx(submission_data: dict, output_path: str) -> str:
    """Generate PPTX from submission data if python-pptx is available."""
    try:
        # Try to import and use the pptx generator
        script_dir = Path(__file__).parent.parent.parent / 'pptx-generator' / 'scripts'
        pptx_script = script_dir / 'generate-pptx.py'

        if pptx_script.exists():
            import subprocess
            import tempfile

            # Write submission JSON to temp file
            with tempfile.NamedTemporaryFile(mode='w', suffix='.json', delete=False) as f:
                json.dump(submission_data, f, ensure_ascii=False, indent=2)
                temp_json = f.name

            # Generate PPTX
            pptx_path = output_path.replace('.json', '.pptx')
            result = subprocess.run(
                ['python3', str(pptx_script), temp_json, pptx_path],
                capture_output=True,
                text=True
            )

            # Cleanup temp file
            os.unlink(temp_json)

            if result.returncode == 0:
                return pptx_path
            else:
                print(f"PPTX generation warning: {result.stderr}", file=sys.stderr)
                return None
        else:
            print("PPTX generator script not found", file=sys.stderr)
            return None

    except Exception as e:
        print(f"PPTX generation failed: {e}", file=sys.stderr)
        return None


def main():
    if len(sys.argv) < 3:
        print("Usage: python generate-submission.py <innovation-id> <output-path> [--from-disclosure <path>]", file=sys.stderr)
        sys.exit(1)

    innovation_id = sys.argv[1]
    output_path = sys.argv[2]

    # Ensure output directory exists
    output_dir = Path(output_path).parent
    output_dir.mkdir(parents=True, exist_ok=True)

    # Check if we should read from a disclosure file
    disclosure_data = {}
    if '--from-disclosure' in sys.argv:
        idx = sys.argv.index('--from-disclosure')
        if idx + 1 < len(sys.argv):
            disclosure_path = sys.argv[idx + 1]
            with open(disclosure_path, 'r', encoding='utf-8') as f:
                disclosure_data = json.load(f)
    elif not sys.stdin.isatty():
        # Read from stdin
        try:
            input_text = sys.stdin.read()
            disclosure_data = json.loads(input_text)
        except json.JSONDecodeError as e:
            print(f"Error parsing JSON from stdin: {e}", file=sys.stderr)
            sys.exit(1)
    else:
        # Create minimal structure
        disclosure_data = {
            "metadata": {
                "title": f"Innovation {innovation_id}",
                "application_number": f"VS-{innovation_id}"
            }
        }

    # Generate submission structure
    submission = create_submission_structure(disclosure_data)

    # Write JSON to file
    with open(output_path, 'w', encoding='utf-8') as f:
        json.dump(submission, f, ensure_ascii=False, indent=2)

    print(f"Submission JSON written to: {output_path}")

    # Try to generate PPTX
    pptx_path = generate_pptx(submission, output_path)
    if pptx_path:
        print(f"Submission PPTX written to: {pptx_path}")

    return output_path


if __name__ == "__main__":
    main()
