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
    # Generate Markdown from disclosure JSON
    python3 -c "
import json
with open('$INPUT_FILE') as f:
    data = json.load(f)
md = []
meta = data.get('metadata', {})
md.append('---')
md.append(f'title: \"{meta.get(\"title\", \"Patent Disclosure\")}\"')
md.append(f'application_number: \"{meta.get(\"application_number\", \"TBD\")}\"')
md.append(f'priority_date: \"{meta.get(\"priority_date\", \"TBD\")}\"')
md.append('inventors:')
for inv in meta.get('inventors', ['TBD']):
    md.append(f'  - \"{inv}\"')
md.append(f'assignee: \"{meta.get(\"assignee\", \"TBD\")}\"')
md.append('---')
md.append('')
fields = meta.get('field_of_invention', [])
if fields:
    md.append('# Field of Invention')
    md.append('')
    md.append(', '.join(fields))
    md.append('')
abstract = data.get('abstract', {})
if abstract:
    md.append('# Abstract')
    md.append('')
    if abstract.get('en'):
        md.append(abstract['en'])
        md.append('')
    if abstract.get('zh_tw'):
        md.append('**摘要 (Traditional Chinese)**')
        md.append('')
        md.append(abstract['zh_tw'])
        md.append('')
problem = data.get('problem_statement', {})
if problem.get('background'):
    md.append('# Problem Statement')
    md.append('')
    for para in problem['background']:
        md.append(para)
        md.append('')
summary = data.get('summary', {})
if summary.get('overview'):
    md.append('# Summary of Invention')
    md.append('')
    for para in summary['overview']:
        md.append(para)
        md.append('')
detail = data.get('detailed_description', {})
if detail:
    md.append('# Detailed Description')
    md.append('')
    if detail.get('system_architecture'):
        md.append('## System Architecture')
        md.append('')
        md.append(detail['system_architecture'])
        md.append('')
    if detail.get('components'):
        md.append('## Components')
        md.append('')
        for comp in detail['components']:
            weight = f' (Weight: {comp[\"weight\"]})' if comp.get('weight') else ''
            md.append(f'### {comp[\"name\"]}{weight}')
            md.append('')
            md.append(comp.get('description', ''))
            md.append('')
            for sub in comp.get('sub_components', []):
                md.append(f'**{sub[\"name\"]}**: {sub.get(\"description\", \"\")}')
                md.append('')
    if detail.get('formulas'):
        md.append('## Formulas')
        md.append('')
        for formula in detail['formulas']:
            md.append(f'**{formula[\"name\"]}**')
            md.append('')
            md.append(f'\`{formula[\"expression\"]}\`')
            md.append('')
claims = data.get('claims', [])
if claims:
    md.append('# Claims')
    md.append('')
    for claim in claims:
        prefix = '' if claim.get('claim_type') == 'independent' else f'(Depends on Claim {claim.get(\"depends_on\", 1)}) '
        md.append(f'**Claim {claim[\"claim_number\"]}**: {prefix}{claim[\"text\"]}')
        md.append('')
drawings = data.get('drawings', [])
if drawings:
    md.append('# Description of Drawings')
    md.append('')
    for drawing in drawings:
        md.append(f'**Figure {drawing[\"figure_number\"]}**: {drawing[\"title\"]}')
        md.append('')
        md.append(drawing.get('description', ''))
        md.append('')
prior = data.get('prior_art', {})
if prior:
    md.append('# Prior Art')
    md.append('')
    for system in prior.get('reviewed_systems', []):
        md.append(f'## {system[\"name\"]}')
        md.append('')
        md.append(system.get('description', ''))
        md.append('')
        if system.get('limitation'):
            md.append(f'**Limitation**: {system[\"limitation\"]}')
            md.append('')
    if prior.get('differentiation'):
        md.append('## Differentiation')
        md.append('')
        md.append(prior['differentiation'])
        md.append('')
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
