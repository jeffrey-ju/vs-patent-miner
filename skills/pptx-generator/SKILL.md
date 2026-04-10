---
name: pptx-generator
description: Generate PowerPoint (PPTX) presentations from patent submission JSON. Automatically triggered after /patent-submission, or manually invoked for existing JSON files.
---

# PPTX Generator

Automatically convert patent submission JSON files to professionally formatted PowerPoint presentations.

## When to Use

- Automatically triggered after `/patent-submission`
- Manual invocation with `/pptx-generator [json-path]`
- Batch conversion with `/pptx-generator --all`

## Dependencies

**Required:** python-pptx

```bash
pip install python-pptx
```

## Output Structure

Based on the ViewSonic patent submission template, generates a 7-slide presentation:

| Slide | Type | Content |
|-------|------|---------|
| 1 | title | 中英文標題、專利編號 |
| 2 | problem | 本發明要解決的問題 (Background) |
| 3 | solution | 本發明提出的解決方案 (Invention) |
| 4 | algorithm | 演算法流程圖 / 技術細節 |
| 5 | advantages | 本發明的技術優勢 |
| 6 | appendix | Appendix: Claims 摘要 |
| 7 | closing | Thank you |

**Supported slide types:** `title`, `problem`, `solution`, `architecture` (alias for algorithm), `algorithm`, `features` (alias for advantages), `advantages`, `claims` (alias for appendix), `appendix`, `closing`

## Process

### Step 1: Check python-pptx

```bash
python3 -c "import pptx; print(pptx.__version__)"
```

### Step 2: Load Submission JSON

```python
with open('submission.json') as f:
    data = json.load(f)
```

### Step 3: Create Presentation

Use the generation script to create PPTX:

```bash
python3 skills/pptx-generator/scripts/generate-pptx.py \
  input.json \
  output.pptx
```

### Step 4: Output Location

```
output/submissions/
├── INV-001-submission.json
└── INV-001-submission.pptx    ← Generated
```

## Commands

| Command | Description |
|---------|-------------|
| `/pptx-generator [path]` | Convert specific JSON to PPTX |
| `/pptx-generator --all` | Convert all JSON files in output/submissions/ |
| `/pptx-generator --check` | Check if python-pptx is installed |

## Slide Design Specifications

### Color Scheme (ViewSonic Theme)

```python
VS_BLUE = RGBColor(0, 82, 147)      # #005293 - Primary
VS_LIGHT_BLUE = RGBColor(0, 120, 212)  # #0078D4 - Accent
VS_GRAY = RGBColor(88, 89, 91)      # #585B5B - Text
VS_WHITE = RGBColor(255, 255, 255)  # #FFFFFF - Background
```

### Typography

| Element | Font | Size | Color |
|---------|------|------|-------|
| Title (ZH) | Microsoft JhengHei | 44pt | VS_BLUE |
| Title (EN) | Calibri | 28pt | VS_GRAY |
| Slide Title | Microsoft JhengHei | 32pt | VS_BLUE |
| Body Text | Microsoft JhengHei | 18pt | VS_GRAY |
| Bullet Points | Microsoft JhengHei | 16pt | VS_GRAY |

### Layout

- Slide size: 16:9 (13.33" x 7.5")
- Margins: 0.5" all sides
- Title position: Top 0.5", Left 0.5"
- Content area: Below title with 0.3" gap

## JSON Input Format

Expected structure from `/patent-submission`:

```json
{
  "metadata": {
    "title_zh": "多維度 OKR 對齊評分系統",
    "title_en": "Multi-Dimensional OKR Alignment Scoring System",
    "patent_id": "VS-OKR-2026-001",
    "date": "2026-04-08"
  },
  "slides": [
    {
      "slide_number": 1,
      "type": "title",
      "content": {
        "title_zh": "...",
        "title_en": "...",
        "subtitle": "Patent Disclosure"
      }
    },
    {
      "slide_number": 2,
      "type": "problem",
      "title": "本發明要解決的問題",
      "content": {
        "bullets": ["問題點 1", "問題點 2", "..."]
      }
    }
  ]
}
```

## Integration

### With patent-submission

After `/patent-submission` completes:

1. Submission JSON generated
2. PPTX generator automatically invoked
3. Both files saved to output/submissions/

### Manual Generation

```bash
# Generate PPTX from existing JSON
/pptx-generator output/submissions/INV-001-submission.json

# Skip PPTX during submission
/patent-submission INV-001 --no-pptx
```

## Customization

### Using Custom Template

```bash
/pptx-generator input.json --template custom-template.pptx
```

### Modifying Default Template

Edit `templates/vs-patent-template.pptx` to change:
- Company logo
- Color scheme
- Slide layouts
- Footer content
