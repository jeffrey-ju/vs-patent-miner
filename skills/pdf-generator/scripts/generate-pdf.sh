#!/bin/bash
# Patent Document PDF Generator
# Usage: ./generate-pdf.sh <input.json> [output.pdf]

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TEMPLATE_DIR="$SCRIPT_DIR/../templates"

INPUT_FILE="$1"
OUTPUT_FILE="${2:-${INPUT_FILE%.json}.pdf}"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Check input file
if [[ -z "$INPUT_FILE" ]]; then
    echo -e "${RED}Error: No input file specified${NC}"
    echo "Usage: $0 <input.json> [output.pdf]"
    exit 1
fi

if [[ ! -f "$INPUT_FILE" ]]; then
    echo -e "${RED}Error: File not found: $INPUT_FILE${NC}"
    exit 1
fi

# Detect document type from JSON structure
DOC_TYPE=$(python3 -c "
import json
import sys
with open('$INPUT_FILE') as f:
    data = json.load(f)
if 'claims' in data:
    print('disclosure')
elif 'slides' in data:
    print('submission')
else:
    print('unknown')
" 2>/dev/null || echo "unknown")

echo -e "${BLUE}Document type: ${DOC_TYPE}${NC}"

# Detect available PDF tool
PDF_TOOL=""
if command -v pandoc &> /dev/null && command -v xelatex &> /dev/null; then
    PDF_TOOL="pandoc"
elif command -v weasyprint &> /dev/null; then
    PDF_TOOL="weasyprint"
elif command -v prince &> /dev/null; then
    PDF_TOOL="prince"
fi

if [[ -z "$PDF_TOOL" ]]; then
    echo -e "${RED}Error: No PDF generation tool found${NC}"
    echo ""
    echo "Please install one of the following:"
    echo "  1. Pandoc + LaTeX (recommended):"
    echo "     brew install pandoc"
    echo "     brew install --cask mactex"
    echo ""
    echo "  2. WeasyPrint:"
    echo "     pip install weasyprint"
    echo ""
    exit 1
fi

echo -e "${BLUE}Using PDF tool: ${PDF_TOOL}${NC}"

# Create temp directory
TEMP_DIR=$(mktemp -d)
trap "rm -rf $TEMP_DIR" EXIT

# Convert JSON to intermediate format
if [[ "$DOC_TYPE" == "disclosure" ]]; then
    # Generate Markdown from disclosure JSON (matches patent disclosure reference format)
    python3 -c "
import json
with open('$INPUT_FILE') as f:
    data = json.load(f)
md = []
meta = data.get('metadata', {})
title = meta.get('title', 'Patent Disclosure')
app_num = meta.get('application_number', 'TBD')
assignee = meta.get('assignee', 'ViewSonic Corporation')
inventors = ', '.join(meta.get('inventors', ['TBD']))
title_zh = meta.get('title_zh', data.get('title_zh', ''))

# YAML frontmatter for LaTeX template
md.append('---')
md.append(f'title: \"{title}\"')
md.append(f'application_number: \"{app_num}\"')
md.append(f'priority_date: \"{meta.get(\"priority_date\", \"To be established upon provisional filing\")}\"')
md.append('inventors:')
for inv in meta.get('inventors', ['TBD']):
    md.append(f'  - \"{inv}\"')
md.append(f'assignee: \"{assignee}\"')
md.append('---')
md.append('')

# Metadata block
fields = meta.get('field_of_invention', [])
if fields:
    md.append(f'**Field of Invention:** {\", \".join(fields)}')
    md.append('')
md.append(f'**Application Number:** {app_num}')
md.append('')
md.append(f'**Priority Date:** {meta.get(\"priority_date\", \"To be established upon provisional filing\")}')
md.append('')
md.append(f'**Inventor(s):** {inventors}')
md.append('')
md.append(f'**Assignee:** {assignee}')
md.append('')

# Section counter
sec = 1

# Abstract
abstract = data.get('abstract', {})
if abstract:
    md.append(f'# {sec}. Abstract')
    md.append('')
    if abstract.get('en'):
        md.append(abstract['en'])
        md.append('')
    if abstract.get('zh_tw'):
        md.append(f'**\\u6458\\u8981 (Traditional Chinese)**')
        md.append('')
        md.append(abstract['zh_tw'])
        md.append('')
    sec += 1

# Problem Statement
problem = data.get('problem_statement', {})
if problem.get('background'):
    md.append(f'# {sec}. Problem Statement (Background of the Invention)')
    md.append('')
    for para in problem['background']:
        md.append(para)
        md.append('')
    sec += 1

# Summary
summary = data.get('summary', {})
if summary.get('overview') or summary.get('key_innovations'):
    md.append(f'# {sec}. Summary of the Invention')
    md.append('')
    for para in summary.get('overview', []):
        md.append(para)
        md.append('')
    innovations = summary.get('key_innovations', [])
    if innovations:
        md.append('**Key Innovations:**')
        md.append('')
        for inn in innovations:
            md.append(f'- {inn}')
        md.append('')
    sec += 1

# Detailed Description
detail = data.get('detailed_description', {})
if detail:
    detail_sec = sec
    md.append(f'# {detail_sec}. Detailed Description of the Preferred Embodiment')
    md.append('')
    subsec = 1

    if detail.get('system_architecture'):
        md.append(f'## {detail_sec}.{subsec} System Architecture')
        md.append('')
        md.append(detail['system_architecture'])
        md.append('')
        subsec += 1

    for comp in detail.get('components', []):
        weight = f' (Weight: {comp[\"weight\"]})' if comp.get('weight') else ''
        md.append(f'## {detail_sec}.{subsec} {comp[\"name\"]}{weight}')
        md.append('')
        md.append(comp.get('description', ''))
        md.append('')

        for sub in comp.get('sub_components', []):
            md.append(f'- **{sub[\"name\"]}**: {sub.get(\"description\", \"\")}')
        if comp.get('sub_components'):
            md.append('')
        subsec += 1

    if detail.get('formulas'):
        md.append(f'## {detail_sec}.{subsec} Formulas and Algorithms')
        md.append('')
        for formula in detail['formulas']:
            md.append(f'**{formula[\"name\"]}**')
            md.append('')
            md.append(f'\`{formula[\"expression\"]}\`')
            md.append('')
            if formula.get('variables'):
                for var, desc in formula['variables'].items():
                    md.append(f'- *{var}*: {desc}')
                md.append('')
        subsec += 1

    # Bilingual support
    if detail.get('bilingual_support'):
        md.append(f'## {detail_sec}.{subsec} Bilingual Support')
        md.append('')
        bl = detail['bilingual_support']
        if isinstance(bl, str):
            md.append(bl)
        elif isinstance(bl, dict):
            for k, v in bl.items():
                md.append(f'**{k}**: {v}')
                md.append('')
        md.append('')
        subsec += 1

    # Caching/performance
    if detail.get('caching_performance'):
        md.append(f'## {detail_sec}.{subsec} Caching and Performance')
        md.append('')
        cp = detail['caching_performance']
        if isinstance(cp, str):
            md.append(cp)
        elif isinstance(cp, dict):
            for k, v in cp.items():
                md.append(f'**{k}**: {v}')
                md.append('')
        md.append('')
        subsec += 1

    sec += 1

# Claims
claims = data.get('claims', [])
if claims:
    md.append(f'# {sec}. Draft Patent Claims')
    md.append('')
    md.append('*Note: These are preliminary claims for discussion with patent counsel. Final claim language will be refined during formal prosecution.*')
    md.append('')
    ind_claims = [c for c in claims if c.get('claim_type') == 'independent']
    dep_claims = [c for c in claims if c.get('claim_type') != 'independent']
    if ind_claims:
        md.append('## Independent Claims')
        md.append('')
        for claim in ind_claims:
            md.append(f'**Claim {claim[\"claim_number\"]}.** {claim[\"text\"]}')
            md.append('')
    if dep_claims:
        md.append('## Dependent Claims')
        md.append('')
        for claim in dep_claims:
            md.append(f'**Claim {claim[\"claim_number\"]}.** {claim[\"text\"]}')
            md.append('')
    sec += 1

# Drawings
import subprocess, os, tempfile
drawings = data.get('drawings', [])
if drawings:
    md.append(f'# {sec}. Description of Drawings')
    md.append('')

    # Check if mermaid-cli is available
    has_mmdc = False
    try:
        subprocess.run(['mmdc', '--version'], capture_output=True, check=True)
        has_mmdc = True
    except (FileNotFoundError, subprocess.CalledProcessError):
        pass

    for drawing in drawings:
        fig_num = drawing.get('figure_number', '')
        title = drawing.get('title', '')
        desc = drawing.get('description', '')
        mermaid = drawing.get('mermaid_code', '')

        md.append(f'### FIG. {fig_num}: {title}')
        md.append('')

        if mermaid and has_mmdc:
            # Render mermaid diagram to PNG
            out_dir = os.path.dirname('$INPUT_FILE') or '.'
            diag_dir = os.path.join(out_dir, 'diagrams')
            os.makedirs(diag_dir, exist_ok=True)
            diag_path = os.path.join(diag_dir, f'fig-{fig_num}.png')

            with tempfile.NamedTemporaryFile(mode='w', suffix='.mmd', delete=False) as mmd:
                mmd.write(mermaid)
                mmd_path = mmd.name

            try:
                subprocess.run(
                    ['mmdc', '-i', mmd_path, '-o', diag_path, '-b', 'transparent', '-w', '800'],
                    capture_output=True, check=True
                )
                md.append(f'![FIG. {fig_num}: {title}]({diag_path})')
                md.append('')
            except subprocess.CalledProcessError:
                md.append(f'*{desc}*')
                md.append('')
            finally:
                os.unlink(mmd_path)
        elif mermaid:
            # Mermaid code present but mmdc not available — show description
            md.append(f'*{desc}*')
            md.append('')
            md.append(f'*(Mermaid diagram available — install mermaid-cli to render: npm install -g @mermaid-js/mermaid-cli)*')
            md.append('')
        else:
            md.append(f'*{desc}*')
            md.append('')
    sec += 1

# Prior Art
prior = data.get('prior_art', {})
if prior:
    md.append(f'# {sec}. Prior Art Differentiation')
    md.append('')
    systems = prior.get('reviewed_systems', [])
    if systems:
        for system in systems:
            name = system.get('name', '')
            stype = system.get('type', '')
            desc = system.get('description', '')
            limitation = system.get('limitation', '')
            line = f'- **{name}**'
            if stype:
                line += f' ({stype})'
            line += f': {desc}'
            if limitation:
                line += f' *Limitation: {limitation}*'
            md.append(line)
        md.append('')
    if prior.get('differentiation'):
        md.append(prior['differentiation'])
        md.append('')
    sec += 1

print('\n'.join(md))
" > "$TEMP_DIR/document.md"

elif [[ "$DOC_TYPE" == "submission" ]]; then
    # Generate HTML from submission JSON
    python3 -c "
import json

with open('$INPUT_FILE') as f:
    data = json.load(f)

html = ['<!DOCTYPE html>', '<html>', '<head>',
    '<meta charset=\"UTF-8\">',
    '<link rel=\"stylesheet\" href=\"$TEMPLATE_DIR/submission-slides.css\">',
    '</head>', '<body>']

for slide in data.get('slides', []):
    slide_type = slide.get('type', 'content')
    slide_num = slide.get('slide_number', 0)
    content = slide.get('content', {})

    html.append(f'<div class=\"slide {slide_type}\">')

    if slide_type == 'title':
        html.append(f'<h1>{content.get(\"title_zh\", \"\")}</h1>')
        html.append(f'<h2>{content.get(\"title_en\", \"\")}</h2>')
        html.append(f'<div class=\"subtitle\">{content.get(\"subtitle\", \"\")}</div>')
        html.append(f'<div class=\"metadata\">')
        html.append(f'<span>{content.get(\"application_number\", \"\")}</span>')
        html.append(f'<span>{content.get(\"date\", \"\")}</span>')
        html.append('</div>')
    else:
        if slide.get('title'):
            html.append(f'<h1>{slide[\"title\"]}</h1>')

        if content.get('bullets'):
            html.append('<ul>')
            for bullet in content['bullets']:
                html.append(f'<li>{bullet}</li>')
            html.append('</ul>')

        if content.get('diagram_description'):
            html.append('<div class=\"diagram\">')
            html.append(f'<p class=\"diagram-description\">{content[\"diagram_description\"]}</p>')
            html.append('</div>')

    html.append(f'<div class=\"slide-number\">{slide_num}</div>')
    html.append('</div>')

html.extend(['</body>', '</html>'])
print('\n'.join(html))
" > "$TEMP_DIR/document.html"
fi

# Generate PDF based on tool
if [[ "$PDF_TOOL" == "pandoc" ]]; then
    if [[ "$DOC_TYPE" == "disclosure" ]]; then
        pandoc "$TEMP_DIR/document.md" \
            -o "$OUTPUT_FILE" \
            --pdf-engine=xelatex \
            --template="$TEMPLATE_DIR/disclosure.latex" \
            -V geometry:margin=1in \
            -V fontsize=11pt \
            --toc \
            --toc-depth=2
    else
        # For submissions, convert HTML first if using pandoc
        pandoc "$TEMP_DIR/document.html" \
            -o "$OUTPUT_FILE" \
            --pdf-engine=xelatex \
            -V geometry:margin=0 \
            -V papersize=a4paper \
            -V classoption=landscape
    fi
elif [[ "$PDF_TOOL" == "weasyprint" ]]; then
    if [[ "$DOC_TYPE" == "disclosure" ]]; then
        # Convert MD to HTML first
        pandoc "$TEMP_DIR/document.md" -o "$TEMP_DIR/document.html" --standalone
        weasyprint "$TEMP_DIR/document.html" "$OUTPUT_FILE" \
            --stylesheet "$TEMPLATE_DIR/disclosure.css"
    else
        weasyprint "$TEMP_DIR/document.html" "$OUTPUT_FILE" \
            --stylesheet "$TEMPLATE_DIR/submission-slides.css"
    fi
elif [[ "$PDF_TOOL" == "prince" ]]; then
    if [[ "$DOC_TYPE" == "disclosure" ]]; then
        pandoc "$TEMP_DIR/document.md" -o "$TEMP_DIR/document.html" --standalone
        prince "$TEMP_DIR/document.html" -o "$OUTPUT_FILE" \
            -s "$TEMPLATE_DIR/disclosure.css"
    else
        prince "$TEMP_DIR/document.html" -o "$OUTPUT_FILE" \
            -s "$TEMPLATE_DIR/submission-slides.css"
    fi
fi

if [[ -f "$OUTPUT_FILE" ]]; then
    echo -e "${GREEN}PDF generated successfully: $OUTPUT_FILE${NC}"
else
    echo -e "${RED}Failed to generate PDF${NC}"
    exit 1
fi
