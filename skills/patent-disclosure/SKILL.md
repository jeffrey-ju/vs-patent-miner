---
name: patent-disclosure
description: Scan a codebase for patentable innovations and generate patent disclosure documents (JSON + PDF with Mermaid diagrams + quality score). Invoked as /patent-disclosure or /patent-disclosure [innovation-id].
---

# Patent Disclosure Skill

**This is an action script, not documentation.** When invoked, you MUST immediately start calling tools. Do not summarise these instructions back to the user.

## What to do when invoked

### If no innovation ID provided (`/patent-disclosure`)

1. **Scan the codebase** — use the Agent tool with `subagent_type: "Explore"` to find 3-5 patentable innovations. Look in `src/`, `backend/`, `lib/` for novel algorithms, scoring systems, security modules, ML pipelines.

2. **For each innovation found, execute the flow below.**

### If innovation ID provided (`/patent-disclosure INV-001`)

Go directly to the flow below for that specific innovation.

---

## Flow per innovation (execute all 6 steps)

### Step 1: Read the actual source code

Use the Read tool to load the primary source files for the innovation. Extract real algorithms, formulas, weights, data structures, function names. **Do not fabricate details.**

### Step 2: Build the disclosure JSON

Create a JSON object with ALL 8 sections. Use this exact shape:

```json
{
  "metadata": {
    "title": "Concise invention title",
    "title_zh": "繁體中文標題",
    "field_of_invention": ["Field 1", "Field 2"],
    "application_number": "VS-INV-XXX-2026",
    "priority_date": "To be established upon provisional filing",
    "inventors": ["Inventor Name"],
    "assignee": "ViewSonic Corporation",
    "innovation_id": "INV-XXX"
  },
  "abstract": {
    "en": "A computer-implemented method for ... (max 150 words)",
    "zh_tw": "一種電腦實施的...方法 (max 300 chars)"
  },
  "problem_statement": {
    "background": ["paragraph 1", "paragraph 2", "paragraph 3"]
  },
  "summary": {
    "overview": ["paragraph 1", "paragraph 2"],
    "key_innovations": ["innovation 1", "innovation 2", "innovation 3"]
  },
  "detailed_description": {
    "system_architecture": "Architecture paragraph",
    "components": [
      {"name": "Component 1", "weight": 0.4, "description": "...", "sub_components": [{"name": "...", "description": "..."}]}
    ],
    "formulas": [
      {"name": "Formula name", "expression": "math expression", "variables": {"x": "definition"}}
    ]
  },
  "claims": [
    {"claim_number": 1, "claim_type": "independent", "text": "A computer-implemented method for... comprising: (a)... (b)... (c)..."},
    {"claim_number": 2, "claim_type": "independent", "text": "A system comprising: a processor; and a non-transitory computer-readable medium..."},
    {"claim_number": 3, "claim_type": "independent", "text": "A non-transitory computer-readable medium storing instructions..."},
    {"claim_number": 4, "claim_type": "dependent", "text": "The method of claim 1, wherein..."}
  ],
  "drawings": [
    {
      "figure_number": 1,
      "title": "System Architecture",
      "description": "Describes what the diagram shows",
      "type": "architecture",
      "mermaid_code": "graph TD\n    A[Input] --> B[Component]\n    B --> C[Output]"
    },
    {
      "figure_number": 2,
      "title": "Process Flowchart",
      "description": "Describes the process flow",
      "type": "flowchart",
      "mermaid_code": "flowchart TD\n    A[Start] --> B{Decision}\n    B -->|Yes| C[Action]"
    },
    {
      "figure_number": 3,
      "title": "Data Flow",
      "description": "Describes the data flow",
      "type": "data_flow",
      "mermaid_code": "graph LR\n    A[Source] --> B[Process] --> C[Store]"
    }
  ],
  "prior_art": {
    "reviewed_systems": [
      {"name": "System Name", "type": "product", "description": "...", "limitation": "..."}
    ],
    "differentiation": "Summary of how this invention differs from prior art"
  }
}
```

**Drawings are REQUIRED.** Every disclosure needs ≥3 drawings, each with `mermaid_code`. The PDF generator renders them as actual diagrams. If you skip this, the PDF will have no figures.

See [references/claim-drafting-guide.md](references/claim-drafting-guide.md) for claim triad templates, antecedent basis rules, and forbidden language.

### Step 3: Write the JSON to disk

Use the Write tool to save the JSON directly:
```
output/disclosures/[INNOVATION-ID]-disclosure.json
```

### Step 4: Generate the PDF

Find the plugin directory and run the PDF script:

```bash
PLUGIN_DIR=$(find ~/.claude /Users -maxdepth 6 -name "generate-pdf.sh" -path "*/vs-patent-miner/*" 2>/dev/null | head -1 | xargs dirname | xargs dirname | xargs dirname)
"$PLUGIN_DIR/skills/pdf-generator/scripts/generate-pdf.sh" \
  output/disclosures/[INNOVATION-ID]-disclosure.json \
  output/disclosures/[INNOVATION-ID]-disclosure.pdf
```

If pandoc/xelatex/mmdc are missing:
```bash
command -v pandoc &> /dev/null || brew install pandoc
command -v xelatex &> /dev/null || brew install --cask mactex-no-gui
command -v mmdc &> /dev/null || npm install -g @mermaid-js/mermaid-cli
```

**NEVER call pandoc directly. NEVER write your own PDF conversion. Always use generate-pdf.sh — it has the CONFIDENTIAL template, macOS fonts, and Mermaid rendering built in.**

### Step 5: Score the disclosure

Score across 6 dimensions using the rubric in [references/scoring-rubric.md](references/scoring-rubric.md). Output the score report.

### Step 6: Report next step

- If score ≥ 80: recommend `/patent-submission [id]`
- If score < 80: list issues to fix
- Always recommend attorney review before filing

---

## Document sections (all REQUIRED)

1. **Metadata** — title, title_zh, inventors, assignee, field
2. **Abstract** — EN (≤150 words) + TW Chinese (≤300 chars)
3. **Problem Statement** — background paragraphs
4. **Summary** — overview + key_innovations
5. **Detailed Description** — architecture, components, formulas
6. **Claims** — method + system + CRM triad + 5-10 dependents
7. **Drawings** — ≥3 figures with mermaid_code (REQUIRED)
8. **Prior Art** — reviewed systems + differentiation

See [references/claim-drafting-guide.md](references/claim-drafting-guide.md) for claim rules and [references/scoring-rubric.md](references/scoring-rubric.md) for the full scoring rubric.
