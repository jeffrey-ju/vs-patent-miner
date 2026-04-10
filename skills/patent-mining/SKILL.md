---
name: patent-mining
description: Scan any codebase to identify patentable innovations. Use when starting patent analysis on a new project, or when the user asks to find innovations, patentable features, or intellectual property opportunities.
---

# Patent Mining — Innovation Discovery

Systematically scan and analyze codebases to identify patentable innovations.

## When to Use

- User asks to "find patents", "identify innovations", "analyze for IP"
- Starting patent analysis on a new codebase
- Need to discover what's novel in a software project

## Process

### Phase 1: SCAN — Codebase Discovery

1. **Read project documentation**
   - README files
   - Architecture docs
   - API documentation
   - Design documents

2. **Analyze code structure**
   - Identify core modules and their purposes
   - Find complex algorithms and data structures
   - Locate AI/ML implementations
   - Discover unique system architectures

3. **Identify innovation candidates**
   - Look for custom algorithms (not standard library usage)
   - Find novel data processing pipelines
   - Identify unique UI/UX patterns
   - Discover innovative integrations

### Phase 2: CLASSIFY — Innovation Categorization

Classify each candidate into one of these categories:

| Category | Indicators | Example Patterns |
|----------|------------|------------------|
| **AI/ML Innovation** | Custom models, scoring systems, prompt engineering, embeddings | `*_score`, `*_predict`, `*_classify`, DSPy/LangChain modules |
| **Data Processing** | Novel indexing, caching, retrieval methods | `*_cache`, `*_index`, RAG implementations |
| **System Architecture** | Unique service designs, workflows, state machines | Event buses, workflow engines, state transitions |
| **Security/Privacy** | Novel auth, access control, data protection | RBAC, scope-based access, input sanitization |
| **User Interface** | Innovative interactions, visualizations, real-time updates | SSE streaming, progressive rendering, novel charts |
| **Multilingual/i18n** | Language detection, bilingual processing | CJK detection, language-aware validation |
| **Performance** | Unique caching, parallelization, optimization | LRU caches, batch processing, lazy loading |

### Phase 3: EVALUATE — Novelty Assessment

For each innovation candidate, assess:

1. **Novelty Score (0-100)**
   - 80-100: Highly novel, likely patentable
   - 60-79: Moderately novel, potential patent
   - 40-59: Some novelty, needs differentiation
   - 0-39: Common pattern, unlikely patentable

2. **Technical Depth**
   - Complexity of implementation
   - Number of interacting components
   - Uniqueness of approach

3. **Business Value**
   - Competitive advantage
   - Market differentiation
   - Customer benefit

### Phase 4: DOCUMENT — Innovation Registry

**CRITICAL: You MUST execute the save script to write results to disk.**

**Output location:** All output files are saved to the **scanned project's directory** (current working directory), NOT the plugin installation directory.

After completing the scan (Phases 1-3), you MUST:

1. Create the scan results JSON object
2. Pipe the JSON to the save script (use absolute path to script, relative path for output):

```bash
# Find the plugin's script location
PLUGIN_SCRIPT=$(find ~/.claude -name "save-scan-results.py" -path "*/vs-patent-miner/*" 2>/dev/null | head -1)

# Save to CURRENT PROJECT directory (where you are scanning)
cat << 'EOF' | python3 "$PLUGIN_SCRIPT" ./output/scans/[PROJECT]-scan.json
{
  "scan_metadata": {
    "project_name": "string",
    "scan_date": "ISO date",
    "directories_scanned": ["string"],
    "files_analyzed": number
  },
  "innovations": [
    {
      "id": "INV-001",
      "title": "string",
      "category": "AI/ML | Data | Architecture | Security | UI | i18n | Performance",
      "novelty_score": number,
      "summary": "1-2 sentence description",
      "technical_details": "string",
      "source_files": ["string"],
      "key_features": ["string"],
      "prior_art_notes": "string",
      "status": "candidate | validated | rejected"
    }
  ]
}
EOF
```

3. Verify the file was created in the **current project**:
```bash
ls -la ./output/scans/
```

**DO NOT skip the script execution. The script ensures files are written to disk and validates the JSON structure.**

**IMPORTANT:** Output paths like `./output/scans/` are relative to the current working directory (the project being scanned), not the plugin directory.

## Commands

- `/patent-mining` — Scan codebase, identify all innovations

## Dependencies

### Context7 Integration

When Context7 MCP is available, the plugin can:

1. **Search technical documentation** for similar implementations
2. **Find prior art** in libraries and frameworks
3. **Validate novelty** against existing solutions

**Check Context7 availability:**
```
Use context7:resolve-library-id to test if MCP is configured
```

**If Context7 unavailable:**
- Plugin still works for codebase scanning
- Prior art search falls back to manual guidance
- Disclosure generation works without automated prior art

## Innovation Identification Patterns

### AI/ML Patterns to Look For

```
- Custom scoring/ranking algorithms
- Multi-dimensional evaluation systems
- Conversational AI with state management
- Prompt engineering techniques
- Embedding-based similarity systems
- Language detection and processing
```

### Architecture Patterns to Look For

```
- Event-driven notification systems
- Hierarchical data traversal with fallbacks
- Scope-aware document retrieval
- Dynamic weight adjustment based on context
- State machines with complex transitions
- Workflow orchestration systems
```

### UI/UX Patterns to Look For

```
- Progressive content streaming
- Real-time collaborative features
- Novel visualization techniques
- Adaptive interfaces based on user role
- Accessibility innovations
```

## Output

After scanning, you MUST produce:

1. **Saved JSON File** — `./output/scans/[PROJECT]-scan.json` in the **scanned project directory**
2. **Innovation Summary** — Quick overview of all candidates (displayed to user)
3. **Recommendations** — Which to pursue for patent disclosure

**Output file structure (in the scanned project):**
```
[PROJECT_BEING_SCANNED]/
└── output/
    └── scans/
        └── [PROJECT]-scan.json    # Scan results with all innovations
```

The saved JSON file is required for subsequent `/patent-disclosure` commands to reference innovation IDs.

**Note:** All output goes to the project you are scanning, not the plugin installation directory.

## Next Steps

After identifying innovations, use:
1. `/patent-disclosure [id]` — Generate disclosure document (includes prior art search)
2. `/patent-submission [id]` — Generate submission presentation

## Context7 Usage Examples

### Search for Similar Implementations

```
# Step 1: Identify relevant libraries
context7:resolve-library-id
  libraryName: "langchain"
  query: "document retrieval scoring"

# Step 2: Search for similar features
context7:query-docs
  libraryId: "/langchain-ai/langchain"
  query: "weighted document retrieval with context"
```

### Validate Innovation Novelty

```
# Check if feature exists in popular frameworks
For each innovation:
  1. Identify related libraries (e.g., DSPy, LangChain, FastAPI)
  2. Search Context7 for similar features
  3. Document any overlap found
  4. Assess differentiation
```
