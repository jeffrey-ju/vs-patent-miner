# VS Patent Miner

A Claude Code plugin that analyzes any codebase to identify patentable innovations and generates structured patent documentation (JSON, PDF, PPTX).

## Features

- **Universal Codebase Analysis** — Works with any programming language and project type
- **Innovation Discovery** — Identifies novel algorithms, architectures, and methods
- **Prior Art Search** — Integrated search via Context7 and web resources
- **Structured Output** — Generates JSON, PDF (disclosure), and PPTX (submission)
- **Bilingual Support** — Handles English and Chinese content
- **Automated Generation** — Scripts ensure files are written to disk

---

## Prerequisites

### Required

| Tool | Purpose | Install |
|------|---------|---------|
| **Claude Code** | Plugin host | [claude.ai/code](https://claude.ai/code) |
| **Python 3.8+** | Script execution | Pre-installed on macOS/Linux |

### Recommended

| Tool | Purpose | Install |
|------|---------|---------|
| **python-pptx** | PPTX generation | `pip install python-pptx` |
| **Context7** | Prior art search | `npx ctx7 setup --claude` |

### Optional (PDF Generation)

Choose one of these for PDF output:

| Tool | Purpose | Install |
|------|---------|---------|
| **Pandoc + LaTeX** | Professional PDFs with CJK support | `brew install pandoc && brew install --cask mactex` |
| **WeasyPrint** | HTML-based PDF generation | `brew install weasyprint` |

### Optional (Diagrams)

| Tool | Purpose | Install |
|------|---------|---------|
| **Mermaid CLI** | Render architecture diagrams | `brew install mermaid-cli` |

---

## Installation

### Option 1: Marketplace Install

```bash
/plugin marketplace add jeffrey-ju/vs-patent-miner
/plugin install vs-patent-miner@jeffrey-ju

# IMPORTANT: Install Python dependency for PPTX generation
pip install python-pptx
```

### Option 2: Clone and Link

```bash
# Clone the repository
git clone https://github.com/jeffrey-ju/vs-patent-miner.git

# Install Python dependencies
cd vs-patent-miner
pip install -r requirements.txt

# Link to Claude Code (add to your project's .claude/settings.json)
```

Add to your project's `.claude/settings.json`:

```json
{
  "plugins": [
    "/path/to/vs-patent-miner"
  ]
}
```

### Verify Installation

When you start a Claude Code session in a directory with this plugin, you should see:

```
🔍 VS Patent Miner — Checking dependencies...

📄 PDF generation available
📊 PPTX generation available
✅ All dependencies satisfied
```

---

## Quick Start

```bash
# 1. Navigate to your project
cd /path/to/your/project

# 2. Scan for innovations
/patent-mining

# 3. Generate disclosure (JSON + PDF)
/patent-disclosure INV-001

# 4. Generate submission (JSON + PPTX)
/patent-submission INV-001
```

---

## Commands

### Patent Mining

| Command | Description |
|---------|-------------|
| `/patent-mining` | Scan codebase, identify all innovations |

### Patent Disclosure

| Command | Description |
|---------|-------------|
| `/patent-disclosure [id]` | Generate disclosure (JSON + PDF) |
| `/patent-disclosure [id] --no-pdf` | Generate JSON only |
| `/patent-disclosure --all` | Generate all disclosures |

### Patent Submission

| Command | Description |
|---------|-------------|
| `/patent-submission [id]` | Generate submission (JSON + PPTX) |
| `/patent-submission [id] --no-pptx` | Generate JSON only |
| `/patent-submission --from-disclosure [path]` | Generate from existing disclosure |

### Utilities

| Command | Description |
|---------|-------------|
| `/pdf-generator [path]` | Generate PDF from JSON |
| `/pptx-generator [path]` | Generate PPTX from JSON |

---

## Output Structure

All output files are saved to the **project you are scanning**, not the plugin installation directory:

```
[YOUR_PROJECT]/
└── output/
    ├── scans/
    │   └── [PROJECT]-scan.json        # Scan results from /patent-mining
    ├── disclosures/
    │   ├── INV-001-disclosure.json    # Structured disclosure data
    │   └── INV-001-disclosure.pdf     # Formatted PDF document
    └── submissions/
        ├── INV-001-submission.json    # Structured slide data
        └── INV-001-submission.pptx    # PowerPoint presentation
```

---

## Disclosure Document Structure

The disclosure JSON contains 8 required sections:

1. **Metadata** — Title, title_zh, application number, inventors, assignee, field of invention
2. **Abstract** — English (max 150 words) and Traditional Chinese (max 300 chars) abstracts
3. **Problem Statement** — Background and limitations of existing approaches
4. **Summary of Invention** — High-level solution overview and key innovations
5. **Detailed Description** — Components, architecture, formulas, algorithms
6. **Claims** — Independent (method/system/CRM triad) and dependent patent claims
7. **Drawings** — Architecture diagrams with Mermaid code (required for PDF rendering)
8. **Prior Art** — Reviewed systems and differentiation

---

## Submission Presentation Structure

The submission PPTX contains 7 slides:

| Slide | Content |
|-------|---------|
| 1 | Title (中英文雙語) |
| 2 | 本發明要解決的問題 (Background) |
| 3 | 本發明提出的解決方案 (Invention) |
| 4 | 演算法流程圖 (Algorithm) |
| 5 | 本發明的技術優勢 (Advantages) |
| 6 | Appendix: Claims 摘要 |
| 7 | Thank you |

---

## Innovation Categories

The plugin recognizes these innovation types:

| Category | Indicators |
|----------|------------|
| **AI/ML** | Custom algorithms, scoring systems, prompt engineering, embeddings |
| **Data Processing** | Novel indexing, caching, retrieval methods |
| **System Architecture** | Unique service designs, workflows, state machines |
| **Security/Privacy** | Novel auth, access control, data protection |
| **User Interface** | Innovative interactions, visualizations, real-time updates |
| **Multilingual** | Language detection, bilingual processing |
| **Performance** | Unique caching, parallelization, optimization |

---

## Example Workflow

```bash
# 1. Scan your project
/patent-mining

# Output:
# Found 5 innovation candidates:
# INV-001: Multi-Dimensional Scoring System (Novelty: 85)
# INV-002: AI Competency Assessment (Novelty: 78)
# ...

# 2. Generate disclosure for top candidate
/patent-disclosure INV-001

# Output:
# Disclosure written to: output/disclosures/INV-001-disclosure.json
# (PDF generation attempted if tools available)

# 3. Generate presentation
/patent-submission INV-001

# Output:
# Submission JSON written to: output/submissions/INV-001-submission.json
# Submission PPTX written to: output/submissions/INV-001-submission.pptx
```

---

## Customization

### Adding Custom Innovation Patterns

Edit `skills/patent-mining/references/scan-patterns.md` to add domain-specific patterns.

### Modifying Disclosure Schema

Edit `skills/patent-disclosure/references/disclosure-schema.json` to adjust the disclosure structure.

### Customizing PPTX Template

Edit `skills/pptx-generator/scripts/generate-pptx.py` to change:
- Color scheme (VS_BLUE, VS_GRAY, etc.)
- Font choices (FONT_ZH, FONT_EN)
- Slide layouts

### Customizing PDF Template

Edit templates in `skills/pdf-generator/templates/`:
- `disclosure.latex` — LaTeX template for Pandoc
- `disclosure.css` — CSS for WeasyPrint

---

## Troubleshooting

### "No output files generated"

Ensure the generation scripts are being executed. Check:
```bash
ls -la output/disclosures/
ls -la output/submissions/
```

If directories don't exist, create them:
```bash
mkdir -p output/disclosures output/submissions
```

### "PPTX generation unavailable"

Install python-pptx:
```bash
pip install python-pptx
```

### "PDF generation unavailable"

Install one of:
```bash
# Option A: Pandoc + LaTeX
brew install pandoc
brew install --cask mactex

# Option B: WeasyPrint
brew install weasyprint
```

### "Context7 not found"

Install Context7 MCP:
```bash
npx ctx7 setup --claude
```

---

## Plugin Structure

```
vs-patent-miner/
├── .claude-plugin/
│   ├── plugin.json              # Plugin metadata
│   └── marketplace.json         # Marketplace listing
├── hooks/
│   ├── hooks.json               # SessionStart hook registration
│   └── check-dependencies.sh    # Dependency checker (uses CLAUDE_PLUGIN_ROOT env var)
├── skills/
│   ├── patent-mining/           # Innovation discovery
│   ├── patent-disclosure/       # Disclosure generation
│   ├── patent-submission/       # Submission generation
│   ├── pdf-generator/           # PDF generation
│   └── pptx-generator/          # PPTX generation
├── docs/
│   └── usage.md                 # Detailed usage guide
├── requirements.txt             # Python dependencies
└── README.md
```

---

## License

MIT

---

## Author

Jeffrey Ju

---

## Support

For questions or issues, contact the author or submit an issue on GitHub.
