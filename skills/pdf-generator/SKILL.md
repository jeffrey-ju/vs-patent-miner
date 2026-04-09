---
name: pdf-generator
description: Convert JSON disclosures and submissions to PDF documents. Automatically triggered after document generation, or manually invoked for existing JSON files.
---

# PDF Generator

**ALWAYS use the `generate-pdf.sh` script from this plugin. NEVER call `pandoc` directly — the script has the correct fonts (macOS Songti TC/Heiti TC), CONFIDENTIAL template, and Mermaid diagram rendering.**

Convert patent disclosure and submission JSON files to professionally formatted PDF documents.

## When to Use

- Automatically triggered after `/patent-disclosure` or `/patent-submission`
- Manual invocation with `/pdf-generator [json-path]`
- Batch conversion with `/pdf-generator --all`

## Dependencies

**Required:** One of the following PDF generation tools:

| Tool | Install | Best For |
|------|---------|----------|
| Pandoc + LaTeX | `brew install pandoc` + `brew install --cask mactex` | Professional documents |
| WeasyPrint | `pip install weasyprint` | HTML-based styling |
| Prince | Commercial license | High-quality output |

## Process

### Step 1: Detect Available Tool

```bash
# Check in order of preference
1. pandoc --version  → Use Pandoc workflow
2. weasyprint --version → Use WeasyPrint workflow
3. prince --version → Use Prince workflow
4. None available → Output instructions for installation
```

### Step 2: Load JSON Document

```python
# Read disclosure or submission JSON
with open(json_path) as f:
    data = json.load(f)

# Detect document type from structure
if "claims" in data:
    doc_type = "disclosure"
elif "slides" in data:
    doc_type = "submission"
```

### Step 3: Generate Intermediate Format

**For Disclosure → Markdown:**

```markdown
# [Title]

**Application Number:** [number]
**Priority Date:** [date]
**Inventors:** [names]
**Assignee:** [company]

## Field of Invention
[field_of_invention]

## Problem Statement
[background paragraphs]

## Summary of Invention
[overview paragraphs]

## Detailed Description
### System Architecture
[architecture description]

### Components
[component details with weights]

### Formulas
[mathematical expressions]

## Claims
1. [Independent claim]
2. [Dependent claim]
...

## Description of Drawings
- Figure 1: [description]
...

## Prior Art
[prior art analysis]
```

**For Submission → HTML/Markdown:**

```html
<section class="slide" data-slide="1">
  <h1>[title_zh]</h1>
  <h2>[title_en]</h2>
  <p class="meta">[application_number] | [date]</p>
</section>
...
```

### Step 4: Process Mermaid Diagrams

If Mermaid diagrams are present in submission JSON:

```bash
# If mermaid-cli is available
mmdc -i diagram.mmd -o diagram.png -b transparent

# Insert generated image into document
```

### Step 5: Generate PDF

**Pandoc Workflow:**

```bash
pandoc disclosure.md \
  -o disclosure.pdf \
  --pdf-engine=xelatex \
  --template=templates/disclosure.latex \
  -V geometry:margin=1in \
  -V fontsize=11pt \
  -V mainfont="Noto Sans CJK TC" \
  --toc
```

**WeasyPrint Workflow:**

```bash
weasyprint disclosure.html disclosure.pdf \
  --stylesheet=templates/disclosure.css
```

### Step 6: Output Location

```
output/
├── disclosures/
│   ├── INV-001-disclosure.json
│   └── INV-001-disclosure.pdf    ← Generated
└── submissions/
    ├── INV-001-submission.json
    └── INV-001-submission.pdf    ← Generated
```

## Commands

| Command | Description |
|---------|-------------|
| `/pdf-generator [path]` | Convert specific JSON to PDF |
| `/pdf-generator --all` | Convert all JSON files in output/ |
| `/pdf-generator --check` | Check available PDF tools |
| `/pdf-generator --disclosure [id]` | Generate disclosure PDF |
| `/pdf-generator --submission [id]` | Generate submission PDF |

## Templates

### Disclosure Template Structure

```
templates/
├── disclosure.latex          # LaTeX template for Pandoc
├── disclosure.css            # CSS for WeasyPrint
├── disclosure.html           # HTML template
└── submission-slides.html    # Slide deck template
```

### Template Variables

**Disclosure:**
- `$title$` — Patent title
- `$application_number$` — Application ID
- `$inventors$` — Inventor list
- `$date$` — Filing date
- `$body$` — Main content

**Submission:**
- `$slides$` — Array of slide content
- `$diagrams$` — Embedded diagrams

## Integration with Other Skills

### Automatic PDF Generation

After `/patent-disclosure`:
```
1. Disclosure JSON generated
2. PDF generator automatically invoked
3. Both JSON and PDF saved to output/disclosures/
```

After `/patent-submission`:
```
1. Submission JSON generated
2. Mermaid diagrams rendered (if mermaid-cli available)
3. PDF generator automatically invoked
4. Both JSON and PDF saved to output/submissions/
```

### Manual Override

```bash
# Skip PDF generation
/patent-disclosure INV-001 --no-pdf

# Generate PDF later
/pdf-generator output/disclosures/INV-001-disclosure.json
```

## Fallback Behavior

If no PDF tool is available:

1. Output clear installation instructions
2. Still save JSON output
3. Provide manual conversion guidance

```
⚠️  PDF generation requires one of:
    • Pandoc + LaTeX: brew install pandoc && brew install --cask mactex
    • WeasyPrint: pip install weasyprint
    
JSON file saved to: output/disclosures/INV-001-disclosure.json
Run /pdf-generator after installing a PDF tool.
```

## Bilingual Support

Templates support CJK (Chinese, Japanese, Korean) characters:

**Pandoc:** Uses `xelatex` engine with CJK fonts
**WeasyPrint:** Uses CSS `@font-face` with system CJK fonts

Recommended fonts:
- macOS: "Noto Sans CJK TC", "PingFang TC"
- Windows: "Microsoft JhengHei"
- Linux: "Noto Sans CJK TC"
