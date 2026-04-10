#!/usr/bin/env bash
# VS Patent Miner — Dependency Checker
# Runs on SessionStart to verify required and recommended dependencies.
# Prints warnings for missing dependencies.
#
# Environment variables provided by Claude Code:
#   CLAUDE_PLUGIN_ROOT — Absolute path to the plugin installation directory
#
# This script is invoked via hooks/hooks.json on SessionStart.

set -eo pipefail

# Colors for output
RED='\033[0;31m'
YELLOW='\033[0;33m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color

PLUGIN_NAME="vs-patent-miner"
MISSING_REQUIRED=()
MISSING_RECOMMENDED=()

# =============================================================================
# Dependency Definitions
# =============================================================================

# Required dependencies (plugin will not work properly without these)
REQUIRED_DEPS=(
  # None currently - all dependencies are recommended
)

# Recommended dependencies (plugin works but with reduced functionality)
RECOMMENDED_DEPS=(
  "context7"           # Prior art search, documentation lookup
  "superpowers"        # Brainstorming, planning skills
)

# Optional dependencies (for PDF/PPTX generation)
OPTIONAL_DEPS=(
  "pandoc"             # PDF generation (preferred)
  "xelatex"            # LaTeX engine for CJK support
  "weasyprint"         # Alternative PDF generation
  "mermaid-cli"        # Diagram rendering
  "python-pptx"        # PPTX generation
)

MISSING_OPTIONAL=()
PDF_TOOL_AVAILABLE=false
PPTX_AVAILABLE=false

# =============================================================================
# Check Functions
# =============================================================================

check_context7() {
  # Check if Context7 MCP is configured
  # Method 1: Check for ctx7 CLI
  if command -v npx &> /dev/null; then
    if npx ctx7 --version &> /dev/null 2>&1; then
      return 0
    fi
  fi

  # Method 2: Check Claude settings for MCP configuration
  CLAUDE_SETTINGS="${HOME}/.claude/settings.json"
  if [ -f "$CLAUDE_SETTINGS" ]; then
    if grep -q "context7" "$CLAUDE_SETTINGS" 2>/dev/null; then
      return 0
    fi
  fi

  # Method 3: Check project-level settings
  if [ -f ".claude/settings.json" ]; then
    if grep -q "context7" ".claude/settings.json" 2>/dev/null; then
      return 0
    fi
  fi

  return 1
}

check_superpowers() {
  # Check if superpowers plugin is installed
  # Superpowers comes with Claude Code, but check if it's enabled

  CLAUDE_SETTINGS="${HOME}/.claude/settings.json"
  if [ -f "$CLAUDE_SETTINGS" ]; then
    # Superpowers is typically bundled, just check settings exist
    if grep -q "superpowers" "$CLAUDE_SETTINGS" 2>/dev/null; then
      return 0
    fi
  fi

  # Assume superpowers is available by default in Claude Code
  return 0
}

check_pandoc() {
  if command -v pandoc &> /dev/null; then
    return 0
  fi
  return 1
}

check_xelatex() {
  if command -v xelatex &> /dev/null; then
    return 0
  fi
  return 1
}

check_weasyprint() {
  if command -v weasyprint &> /dev/null; then
    return 0
  fi
  return 1
}

check_mermaid_cli() {
  if command -v mmdc &> /dev/null; then
    return 0
  fi
  return 1
}

check_python_pptx() {
  if python3 -c "import pptx" 2>/dev/null; then
    return 0
  fi
  return 1
}

# =============================================================================
# Main Check Logic
# =============================================================================

echo ""
echo "🔍 VS Patent Miner — Checking dependencies..."
echo ""

# Check required dependencies (currently none)
# for dep in "${REQUIRED_DEPS[@]}"; do
#   case "$dep" in
#     *)
#       # Add specific checks as needed
#       ;;
#   esac
# done

# Check recommended dependencies
for dep in "${RECOMMENDED_DEPS[@]}"; do
  case "$dep" in
    "context7")
      if ! check_context7; then
        MISSING_RECOMMENDED+=("context7")
      fi
      ;;
    "superpowers")
      if ! check_superpowers; then
        MISSING_RECOMMENDED+=("superpowers")
      fi
      ;;
  esac
done

# Check optional dependencies (PDF tools)
# At least one PDF tool should be available
if check_pandoc && check_xelatex; then
  PDF_TOOL_AVAILABLE=true
elif check_weasyprint; then
  PDF_TOOL_AVAILABLE=true
fi

if ! check_pandoc; then
  MISSING_OPTIONAL+=("pandoc")
fi
if ! check_xelatex; then
  MISSING_OPTIONAL+=("xelatex")
fi
if ! check_weasyprint; then
  MISSING_OPTIONAL+=("weasyprint")
fi
if ! check_mermaid_cli; then
  MISSING_OPTIONAL+=("mermaid-cli")
fi

# Check python-pptx
if check_python_pptx; then
  PPTX_AVAILABLE=true
fi

# =============================================================================
# Report Results
# =============================================================================

# Report missing required dependencies
if [ ${#MISSING_REQUIRED[@]} -gt 0 ]; then
  echo -e "${RED}❌ Missing REQUIRED dependencies:${NC}"
  for dep in "${MISSING_REQUIRED[@]}"; do
    case "$dep" in
      *)
        echo "   • $dep"
        ;;
    esac
  done
  echo ""
  echo -e "${RED}⚠️  VS Patent Miner may not function correctly.${NC}"
  echo ""
fi

# Report missing recommended dependencies
if [ ${#MISSING_RECOMMENDED[@]} -gt 0 ]; then
  echo -e "${YELLOW}⚠️  Missing RECOMMENDED dependencies:${NC}"
  for dep in "${MISSING_RECOMMENDED[@]}"; do
    case "$dep" in
      "context7")
        echo "   • context7 — Prior art search will be unavailable"
        echo "     Install: npx ctx7 setup --claude"
        ;;
      "superpowers")
        echo "   • superpowers — Brainstorming/planning skills unavailable"
        echo "     Usually bundled with Claude Code"
        ;;
      *)
        echo "   • $dep"
        ;;
    esac
  done
  echo ""
fi

# Report PDF generation status
if [ "$PDF_TOOL_AVAILABLE" = false ]; then
  echo -e "${YELLOW}📄 PDF generation unavailable — no PDF tools found${NC}"
  echo "   Install one of the following:"
  echo "   • Pandoc + LaTeX (recommended):"
  echo "     brew install pandoc"
  echo "     brew install --cask mactex"
  echo "   • WeasyPrint (Python):"
  echo "     pip install weasyprint"
  echo ""
else
  echo -e "${GREEN}📄 PDF generation available${NC}"
fi

# Report PPTX generation status
if [ "$PPTX_AVAILABLE" = true ]; then
  echo -e "${GREEN}📊 PPTX generation available${NC}"
else
  echo -e "${YELLOW}📊 PPTX generation unavailable — python-pptx not found${NC}"
  echo "   Install: pip install python-pptx"
  echo ""
fi

# Report missing Mermaid CLI if not available
if ! check_mermaid_cli; then
  echo -e "${YELLOW}🔷 Mermaid diagrams unavailable — mmdc not found${NC}"
  echo "   Install: npm install -g @mermaid-js/mermaid-cli"
  echo ""
fi

# Success message if all dependencies present
if [ ${#MISSING_REQUIRED[@]} -eq 0 ] && [ ${#MISSING_RECOMMENDED[@]} -eq 0 ] && [ "$PDF_TOOL_AVAILABLE" = true ]; then
  echo -e "${GREEN}✅ All dependencies satisfied${NC}"
  echo ""
fi

# Always exit successfully (don't block session start)
exit 0
