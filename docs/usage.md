# Patent Mining Plugin — Usage Guide

## Quick Start

### Step 1: Navigate to Your Project

```bash
cd /path/to/your/project
```

### Step 2: Run the Scan

```bash
/patent-mining
```

The plugin will:
1. Read README and documentation files
2. Analyze code structure
3. Identify innovation candidates
4. Assess novelty scores
5. Output an innovations registry

### Step 3: Generate Documentation

```bash
# For a specific innovation
/patent-disclosure INV-001

# For all innovations
/patent-disclosure --all
```

---

## Detailed Usage

### Scanning a Codebase

The `/patent-mining` command performs a comprehensive scan:

1. **Documentation Analysis**
   - Reads all `.md` files in the project root
   - Analyzes `docs/` directory
   - Extracts feature descriptions and architecture information

2. **Code Structure Analysis**
   - Identifies core modules
   - Finds algorithm implementations
   - Locates AI/ML components

3. **Innovation Identification**
   - Matches code patterns against innovation categories
   - Scores novelty based on uniqueness
   - Tags source files

**Output File:** `output/scans/[PROJECT]-scan.json`

```json
{
  "scan_metadata": {
    "project_name": "my-project",
    "scan_date": "2026-04-08",
    "files_analyzed": 150
  },
  "innovations": [
    {
      "id": "INV-001",
      "title": "Adaptive Caching Algorithm",
      "category": "Performance",
      "novelty_score": 82,
      "summary": "LRU cache with context-aware eviction",
      "source_files": ["src/cache/adaptive.py"]
    }
  ]
}
```

**Important:** The scan results are automatically saved to disk. This file is required for subsequent `/patent-disclosure` commands.

### Generating Disclosures

The `/patent-disclosure` command creates formal disclosure documents:

**Input:** Innovation ID or direct description

**Process:**
1. Deep-reads all source files
2. Extracts technical specifications
3. Generates problem statement from code context
4. Drafts patent claims
5. Searches prior art (if Context7 available)

**Output:** JSON file following disclosure schema

**Example:**
```bash
/patent-disclosure INV-001
```

Generates `output/disclosures/INV-001-disclosure.json` containing:
- Metadata (title, inventors, application number)
- Problem statement (2-3 paragraphs)
- Summary (2-3 paragraphs)
- Detailed description (components, formulas, configurations)
- Claims (1 independent + 5-10 dependent)
- Drawings (diagram descriptions)
- Prior art differentiation

### Generating Submissions

The `/patent-submission` command creates presentation-ready content:

**Input:** Disclosure JSON or Innovation ID

**Process:**
1. Loads disclosure data
2. Summarizes for presentation format
3. Generates Mermaid diagrams
4. Creates speaker notes

**Output:** JSON file + PPTX presentation (7 slides)

**Example:**
```bash
/patent-submission INV-001
```

Generates:
- `output/submissions/INV-001-submission.json` — Structured data
- `output/submissions/INV-001-submission.pptx` — PowerPoint presentation

**Slide Structure:**
| Slide | Content |
|-------|---------|
| 1 | Title (中英文雙語) |
| 2 | 本發明要解決的問題 (Background) |
| 3 | 本發明提出的解決方案 (Invention) |
| 4 | 演算法流程圖 |
| 5 | 本發明的技術優勢 (Advantages) |
| 6 | Appendix: 示意圖/Claims |
| 7 | Thank you |

---

## Automatic PPTX Generation

Starting with version 1.1.0, `/patent-submission` automatically generates PowerPoint presentations.

### How It Works

When you run `/patent-submission`:

1. **JSON is generated** — Structured slide data saved
2. **python-pptx detected** — Plugin checks for the library
3. **PPTX is generated** — Professional presentation created automatically
4. **Both files saved** — JSON and PPTX available in output directory

### PPTX Requirements

```bash
pip install python-pptx
```

### PPTX Design

The generated PPTX follows ViewSonic branding:
- **Color scheme**: VS Blue (#005293), accent colors
- **Typography**: Microsoft JhengHei (中文), Calibri (English)
- **Layout**: 16:9 aspect ratio
- **Structure**: 7 slides matching the patent submission template

### Skipping PPTX Generation

```bash
/patent-submission INV-001 --no-pptx
```

### Manual PPTX Generation

```bash
/pptx-generator output/submissions/INV-001-submission.json
```

---

## Automatic PDF Generation (Disclosure)

`/patent-disclosure` can automatically generate PDF documents alongside JSON output.

### How It Works

When you run `/patent-disclosure`:

1. **JSON is generated** — Structured disclosure data saved
2. **PDF tool detected** — Plugin checks for Pandoc or WeasyPrint
3. **PDF is generated** — Professional document created automatically
4. **Both files saved** — JSON and PDF available in output directory

### Output Structure

All output files are saved to the **project you are scanning**, not the plugin directory:

```
[YOUR_PROJECT]/
└── output/
    ├── scans/
    │   └── [PROJECT]-scan.json        # Scan results
    ├── disclosures/
    │   ├── INV-001-disclosure.json    # Structured data
    │   └── INV-001-disclosure.pdf     # Formatted document
    └── submissions/
        ├── INV-001-submission.json    # Structured data
        ├── INV-001-submission.pptx    # PowerPoint presentation
        └── diagrams/
            └── INV-001-diagram-1.png  # Rendered Mermaid diagrams
```

### PDF Tool Requirements

Install one of these PDF generation tools:

**Option 1: Pandoc + LaTeX (Recommended)**
```bash
brew install pandoc
brew install --cask mactex
```
- Best for professional documents
- Full CJK (Chinese/Japanese/Korean) support
- High-quality typography

**Option 2: WeasyPrint**
```bash
brew install weasyprint
```
- HTML/CSS-based styling
- Good for web-like layouts
- Easier customization

### Checking PDF Tool Status

```bash
# Check what tools are available
/pdf-generator --check
```

Or run the check script directly:
```bash
./skills/pdf-generator/scripts/check-pdf-tools.sh
```

### Skipping PDF Generation

If you only need JSON output:

```bash
/patent-disclosure INV-001 --no-pdf
/patent-submission INV-001 --no-pdf
```

### Manual PDF Generation

Generate PDF from existing JSON:

```bash
/pdf-generator output/disclosures/INV-001-disclosure.json
```

Or use the script directly:
```bash
./skills/pdf-generator/scripts/generate-pdf.sh \
  output/disclosures/INV-001-disclosure.json \
  output/disclosures/INV-001-disclosure.pdf
```

### Customizing PDF Output

Templates are located in `skills/pdf-generator/templates/`:

| File | Purpose |
|------|---------|
| `disclosure.latex` | LaTeX template for Pandoc |
| `disclosure.css` | CSS for WeasyPrint disclosure |
| `submission-slides.css` | CSS for WeasyPrint slides |

Edit these templates to customize:
- Company branding (colors, logo)
- Font choices
- Layout and margins
- Header/footer content

### Mermaid Diagram Rendering

For submission PDFs with architecture diagrams:

```bash
brew install mermaid-cli
```

Diagrams are automatically rendered to PNG and embedded in the PDF.

---

## Prior Art Search

Prior art search is **integrated into `/patent-disclosure`** (Step 6). When generating a disclosure, the system will:

1. Extract search terms from the innovation
2. Search Context7 for similar implementations (if available)
3. Search patent databases (Google Patents, USPTO, WIPO)
4. Search academic literature (arXiv, IEEE, ACM)
5. Assess relevance and document differentiation

### Recommended Databases

| Type | Database | URL |
|------|----------|-----|
| Patents | Google Patents | https://patents.google.com |
| Patents | USPTO | https://patft.uspto.gov |
| Patents | WIPO | https://patentscope.wipo.int |
| Academic | arXiv | https://arxiv.org |
| Academic | IEEE Xplore | https://ieeexplore.ieee.org |
| Academic | ACM DL | https://dl.acm.org |

### Search Guide

For detailed search strategies, see:
`skills/patent-disclosure/references/prior-art-search-guide.md`

---

## Best Practices

### 1. Review Before Submission

Always have a human review:
- Claim language
- Prior art coverage
- Technical accuracy

### 2. Document Everything

Keep records of:
- Search terms used
- Databases checked
- Why prior art is different

### 3. Iterate on Claims

Start broad, then narrow:
- Independent claim covers the core innovation
- Dependent claims protect specific implementations

### 4. Use Real Examples

When explaining the invention:
- Include concrete numbers
- Show actual configurations
- Reference production code

---

## Troubleshooting

### "No innovations found"

**Possible causes:**
- Project has no README or documentation
- Code follows standard patterns without customization
- Innovation is in test files (excluded by default)

**Solutions:**
- Add documentation describing unique features
- Run with verbose mode to see what was scanned
- Manually describe innovations using direct input

### "Prior art search failed"

**Possible causes:**
- Context7 not configured
- Network issues
- Rate limiting

**Solutions:**
- Check Context7 setup: `npx ctx7 setup --claude`
- Perform manual prior art search
- Wait and retry

### "Disclosure generation incomplete"

**Possible causes:**
- Source files not found
- Insufficient technical detail in code
- Missing comments explaining purpose

**Solutions:**
- Verify source file paths
- Add code comments explaining algorithms
- Provide additional context manually

### "PDF generation failed"

**Possible causes:**
- No PDF tools installed
- Missing CJK fonts
- LaTeX not in PATH

**Solutions:**
- Run `/pdf-generator --check` to verify tools
- Install Pandoc + MacTeX: `brew install pandoc && brew install --cask mactex`
- For CJK support, install Noto CJK fonts
- Restart terminal after installing MacTeX

### "Mermaid diagrams not rendering"

**Possible causes:**
- mermaid-cli not installed
- Node.js not available

**Solutions:**
- Install mermaid-cli: `brew install mermaid-cli`
- Verify with: `mmdc --version`
