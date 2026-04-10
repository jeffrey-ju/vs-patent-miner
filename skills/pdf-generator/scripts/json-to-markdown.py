#!/usr/bin/env python3
"""Convert patent disclosure JSON to Markdown for PDF generation.

Usage: python3 json-to-markdown.py <input.json> <output.md>
"""

import json
import os
import subprocess
import sys
import tempfile


def convert_disclosure(input_file: str, output_file: str) -> None:
    """Convert disclosure JSON to Markdown."""
    with open(input_file, encoding="utf-8") as f:
        data = json.load(f)

    md = []
    meta = data.get("metadata", {})
    title = meta.get("title", "Patent Disclosure")
    app_num = meta.get("application_number", "TBD")
    assignee = meta.get("assignee", "ViewSonic Corporation")
    inventors = ", ".join(meta.get("inventors", ["TBD"]))

    # YAML frontmatter for LaTeX template
    md.append("---")
    md.append(f'title: "{title}"')
    md.append(f'application_number: "{app_num}"')
    md.append(f'priority_date: "{meta.get("priority_date", "To be established upon provisional filing")}"')
    md.append("inventors:")
    for inv in meta.get("inventors", ["TBD"]):
        md.append(f'  - "{inv}"')
    md.append(f'assignee: "{assignee}"')
    md.append("---")
    md.append("")

    # Section counter
    sec = 1

    # Abstract
    abstract = data.get("abstract", {})
    if abstract:
        md.append(f"# {sec}. Abstract")
        md.append("")
        if abstract.get("en"):
            md.append(abstract["en"])
            md.append("")
        if abstract.get("zh_tw"):
            md.append("**摘要 (Traditional Chinese)**")
            md.append("")
            md.append(abstract["zh_tw"])
            md.append("")
        sec += 1

    # Problem Statement
    problem = data.get("problem_statement", {})
    if problem.get("background"):
        md.append(f"# {sec}. Problem Statement (Background of the Invention)")
        md.append("")
        for para in problem["background"]:
            md.append(para)
            md.append("")
        sec += 1

    # Summary
    summary = data.get("summary", {})
    if summary.get("overview") or summary.get("key_innovations"):
        md.append(f"# {sec}. Summary of the Invention")
        md.append("")
        for para in summary.get("overview", []):
            md.append(para)
            md.append("")
        innovations = summary.get("key_innovations", [])
        if innovations:
            md.append("**Key Innovations:**")
            md.append("")
            for inn in innovations:
                md.append(f"- {inn}")
            md.append("")
        sec += 1

    # Detailed Description
    detail = data.get("detailed_description", {})
    if detail:
        detail_sec = sec
        md.append(f"# {detail_sec}. Detailed Description of the Preferred Embodiment")
        md.append("")
        subsec = 1

        if detail.get("system_architecture"):
            md.append(f"## {detail_sec}.{subsec} System Architecture")
            md.append("")
            md.append(detail["system_architecture"])
            md.append("")
            subsec += 1

        for comp in detail.get("components", []):
            weight = f' (Weight: {comp["weight"]})' if comp.get("weight") else ""
            md.append(f'## {detail_sec}.{subsec} {comp["name"]}{weight}')
            md.append("")
            md.append(comp.get("description", ""))
            md.append("")

            for sub in comp.get("sub_components", []):
                md.append(f'- **{sub["name"]}**: {sub.get("description", "")}')
            if comp.get("sub_components"):
                md.append("")
            subsec += 1

        if detail.get("formulas"):
            md.append(f"## {detail_sec}.{subsec} Formulas and Algorithms")
            md.append("")
            for formula in detail["formulas"]:
                md.append(f'**{formula.get("name", "Formula")}**')
                md.append("")
                expr = formula.get("expression", formula.get("formula", ""))
                if expr:
                    md.append(f"`{expr}`")
                    md.append("")
                desc = formula.get("description", "")
                if desc and not formula.get("variables"):
                    md.append(desc)
                    md.append("")
                if formula.get("variables"):
                    for var, vdesc in formula["variables"].items():
                        md.append(f"- *{var}*: {vdesc}")
                    md.append("")
        subsec += 1

        if detail.get("bilingual_support"):
            md.append(f"## {detail_sec}.{subsec} Bilingual Support")
            md.append("")
            bl = detail["bilingual_support"]
            if isinstance(bl, str):
                md.append(bl)
            elif isinstance(bl, dict):
                for k, v in bl.items():
                    md.append(f"**{k}**: {v}")
                    md.append("")
            md.append("")
            subsec += 1

        if detail.get("caching_performance"):
            md.append(f"## {detail_sec}.{subsec} Caching and Performance")
            md.append("")
            cp = detail["caching_performance"]
            if isinstance(cp, str):
                md.append(cp)
            elif isinstance(cp, dict):
                for k, v in cp.items():
                    md.append(f"**{k}**: {v}")
                    md.append("")
            md.append("")
            subsec += 1

        sec += 1

    # Claims
    claims = data.get("claims", [])
    if claims:
        md.append(f"# {sec}. Draft Patent Claims")
        md.append("")
        md.append(
            "*Note: These are preliminary claims for discussion with patent counsel. "
            "Final claim language will be refined during formal prosecution.*"
        )
        md.append("")

        def get_claim_type(c):
            return c.get("claim_type", c.get("type", c.get("category", "")))

        ind_claims = [c for c in claims if get_claim_type(c) == "independent"]
        dep_claims = [c for c in claims if get_claim_type(c) != "independent"]

        if ind_claims:
            md.append("## Independent Claims")
            md.append("")
            for claim in ind_claims:
                num = claim.get("claim_number", claim.get("number", ""))
                md.append(f'**Claim {num}.** {claim.get("text", "")}')
                md.append("")
        if dep_claims:
            md.append("## Dependent Claims")
            md.append("")
            for claim in dep_claims:
                num = claim.get("claim_number", claim.get("number", ""))
                md.append(f'**Claim {num}.** {claim.get("text", "")}')
                md.append("")
        sec += 1

    # Drawings
    drawings = data.get("drawings", [])
    if drawings:
        md.append(f"# {sec}. Description of Drawings")
        md.append("")

        # Check if mermaid-cli is available
        has_mmdc = False
        try:
            subprocess.run(
                ["mmdc", "--version"], capture_output=True, check=True
            )
            has_mmdc = True
        except (FileNotFoundError, subprocess.CalledProcessError):
            pass

        for drawing in drawings:
            fig_num = drawing.get("figure_number", "")
            fig_title = drawing.get("title", "")
            desc = drawing.get("description", "")
            mermaid = drawing.get("mermaid_code", "")

            if mermaid and has_mmdc:
                out_dir = os.path.dirname(input_file) or "."
                diag_dir = os.path.join(out_dir, "diagrams")
                os.makedirs(diag_dir, exist_ok=True)
                diag_path = os.path.join(diag_dir, f"fig-{fig_num}.png")

                with tempfile.NamedTemporaryFile(
                    mode="w", suffix=".mmd", delete=False
                ) as mmd:
                    mmd.write(mermaid)
                    mmd_path = mmd.name

                try:
                    subprocess.run(
                        [
                            "mmdc", "-i", mmd_path, "-o", diag_path,
                            "-b", "transparent", "-w", "600",
                        ],
                        capture_output=True,
                        check=True,
                    )
                    md.append(f"**FIG. {fig_num}: {fig_title}**")
                    md.append("")
                    md.append(f"*{desc}*")
                    md.append("")
                    md.append(f"![FIG. {fig_num}: {fig_title}]({diag_path})")
                    md.append("")
                except subprocess.CalledProcessError:
                    md.append(f"**FIG. {fig_num}: {fig_title}** -- *{desc}*")
                    md.append("")
                finally:
                    os.unlink(mmd_path)
            elif mermaid:
                md.append(f"**FIG. {fig_num}: {fig_title}** -- *{desc}*")
                md.append("")
                md.append(
                    "*(Install mermaid-cli to render: "
                    "npm install -g @mermaid-js/mermaid-cli)*"
                )
                md.append("")
            else:
                md.append(f"**FIG. {fig_num}: {fig_title}** -- *{desc}*")
                md.append("")
        sec += 1

    # Prior Art
    prior = data.get("prior_art", {})
    if prior:
        md.append(f"# {sec}. Prior Art Differentiation")
        md.append("")
        systems = prior.get("reviewed_systems", [])
        if systems:
            for system in systems:
                name = system.get("name", "")
                stype = system.get("type", "")
                desc = system.get("description", "")
                limitation = system.get("limitation", "")
                line = f"- **{name}**"
                if stype:
                    line += f" ({stype})"
                line += f": {desc}"
                if limitation:
                    line += f" *Limitation: {limitation}*"
                md.append(line)
            md.append("")
        if prior.get("differentiation"):
            md.append(prior["differentiation"])
            md.append("")
        sec += 1

    with open(output_file, "w", encoding="utf-8") as f:
        f.write("\n".join(md))

    print(f"Markdown generated: {output_file}")


if __name__ == "__main__":
    if len(sys.argv) < 3:
        print("Usage: python3 json-to-markdown.py <input.json> <output.md>", file=sys.stderr)
        sys.exit(1)
    convert_disclosure(sys.argv[1], sys.argv[2])
