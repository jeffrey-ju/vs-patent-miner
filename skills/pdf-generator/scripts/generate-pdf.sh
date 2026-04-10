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
import json, sys
with open(sys.argv[1]) as f:
    data = json.load(f)
if 'claims' in data:
    print('disclosure')
elif 'slides' in data:
    print('submission')
else:
    print('unknown')
" "$INPUT_FILE" 2>/dev/null || echo "unknown")

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
    # Generate Markdown using standalone Python script (no bash variable expansion issues)
    python3 "$SCRIPT_DIR/json-to-markdown.py" "$INPUT_FILE" "$TEMP_DIR/document.md"

elif [[ "$DOC_TYPE" == "submission" ]]; then
    # Generate HTML from submission JSON
    python3 -c "
import json, sys

with open(sys.argv[1]) as f:
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
            --from=markdown-raw_tex \
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
