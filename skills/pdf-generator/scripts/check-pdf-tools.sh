#!/bin/bash
# Check available PDF generation tools

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}Checking PDF Generation Tools...${NC}"
echo ""

AVAILABLE_TOOLS=0

# Check Pandoc
echo -n "Pandoc: "
if command -v pandoc &> /dev/null; then
    VERSION=$(pandoc --version | head -1)
    echo -e "${GREEN}$VERSION${NC}"
    AVAILABLE_TOOLS=$((AVAILABLE_TOOLS + 1))
else
    echo -e "${RED}Not installed${NC}"
    echo "  Install: brew install pandoc"
fi

# Check XeLaTeX (required for CJK support with Pandoc)
echo -n "XeLaTeX: "
if command -v xelatex &> /dev/null; then
    VERSION=$(xelatex --version | head -1)
    echo -e "${GREEN}Available${NC}"
    AVAILABLE_TOOLS=$((AVAILABLE_TOOLS + 1))
else
    echo -e "${YELLOW}Not installed (required for Pandoc PDF with CJK)${NC}"
    echo "  Install: brew install --cask mactex"
fi

# Check WeasyPrint
echo -n "WeasyPrint: "
if command -v weasyprint &> /dev/null; then
    VERSION=$(weasyprint --version 2>&1)
    echo -e "${GREEN}$VERSION${NC}"
    AVAILABLE_TOOLS=$((AVAILABLE_TOOLS + 1))
else
    echo -e "${RED}Not installed${NC}"
    echo "  Install: pip install weasyprint"
fi

# Check Prince
echo -n "Prince: "
if command -v prince &> /dev/null; then
    VERSION=$(prince --version 2>&1 | head -1)
    echo -e "${GREEN}$VERSION${NC}"
    AVAILABLE_TOOLS=$((AVAILABLE_TOOLS + 1))
else
    echo -e "${YELLOW}Not installed (commercial)${NC}"
    echo "  Website: https://www.princexml.com/"
fi

# Check Mermaid CLI (for diagrams)
echo ""
echo -n "Mermaid CLI: "
if command -v mmdc &> /dev/null; then
    VERSION=$(mmdc --version 2>&1)
    echo -e "${GREEN}$VERSION${NC}"
else
    echo -e "${YELLOW}Not installed (optional, for diagrams)${NC}"
    echo "  Install: npm install -g @mermaid-js/mermaid-cli"
fi

echo ""

if [[ $AVAILABLE_TOOLS -eq 0 ]]; then
    echo -e "${RED}No PDF generation tools available!${NC}"
    echo ""
    echo "Recommended installation (Pandoc + LaTeX):"
    echo "  brew install pandoc"
    echo "  brew install --cask mactex"
    echo ""
    echo "Alternative (WeasyPrint - Python):"
    echo "  pip install weasyprint"
    exit 1
else
    echo -e "${GREEN}PDF generation is available.${NC}"
fi
