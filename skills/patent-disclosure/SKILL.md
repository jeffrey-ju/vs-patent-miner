---
name: patent-disclosure
description: Generate structured JSON for patent disclosure documents. Use after identifying innovations with /patent-mining, or when the user wants to create a patent disclosure for a specific innovation.
---

# Patent Disclosure Generator

Generate comprehensive patent disclosure documents in structured JSON format.

## When to Use

- After running `/patent-mining` to identify innovations
- When user asks to "create disclosure", "write patent", "document innovation"
- When preparing formal patent documentation

## Input Requirements

1. **Innovation ID** from `/patent-mining` scan results, OR
2. **Direct description** of the innovation with:
   - Title
   - Technical description
   - Source file locations
   - Problem it solves

## Output Format

Generate a JSON file following the schema in `references/disclosure-schema.json`.

## Process

### Step 1: Gather Innovation Details

If using innovation ID:
```
1. Load innovation from scan results
2. Read all source files listed
3. Extract technical implementation details
4. Identify key algorithms and data structures
```

If using direct description:
```
1. Search codebase for related files
2. Read and analyze implementation
3. Extract technical details
4. Validate description against code
```

### Step 2: Analyze Problem Statement

Extract from:
- Code comments explaining "why"
- README problem descriptions
- Comparison with alternatives in comments
- Error messages showing what goes wrong without this solution

Generate 2-3 paragraphs covering:
- Current state of the art
- Limitations of existing approaches
- Specific technical problems

### Step 3: Generate Summary

Write 2-3 paragraphs covering:
- High-level solution approach
- Key innovations
- Benefits and improvements

### Step 4: Generate Abstract

Write a concise abstract for both English and Traditional Chinese (繁體中文).

**English abstract rules (USPTO 37 CFR 1.72(b)):**
- Single paragraph, maximum 150 words
- Must state: (1) what the invention is, (2) what problem it solves, (3) how it works
- Do NOT use phrases like "the invention", "this disclosure", or "is disclosed"
- Use the same terminology as Claim 1
- No legal jargon — write for a technical reader

**Traditional Chinese abstract rules (TIPO):**
- Maximum 300 characters (繁體中文)
- Must use Taiwan terminology — see patent-writing-guide.md for term mapping
- Key terms: 演算法 (not 算法), 軟體 (not 软件), 伺服器 (not 服务器)

```json
{
  "abstract": {
    "en": "A computer-implemented method for [what it is] that addresses [problem] by [how it works]. The method comprises [key steps]. The system achieves [key benefit].",
    "zh_tw": "一種電腦實施的[what]方法，透過[how]解決[problem]。該方法包含[key steps]，實現[benefit]。"
  }
}
```

### Step 5: Extract Detailed Description

For each component:

```json
{
  "name": "Component Name",
  "weight": 0.40,  // if applicable
  "description": "Technical description",
  "sub_components": [
    {
      "name": "Sub-component",
      "description": "Details"
    }
  ]
}
```

Include:
- System architecture overview
- Each major component with weights/priorities
- Formulas and algorithms
- Data flows
- Special handling (bilingual, caching, etc.)

### Step 6: Draft Claims

Generate patent claims following the method/system/CRM triad and antecedent basis rules. See `references/patent-writing-guide.md` for the full writing guide.

#### Claim Triad (3 Independent Claims Required)

Proper software patent protection requires three independent claims covering the same concept:

**Independent Claim 1 — Method:**
```
A computer-implemented method for [function], comprising:
(a) receiving, by a processor, [first input];
(b) computing, by the processor, a first [result] by [technical step];
(c) determining, by the processor, a second [result] based on [technical step]; and
(d) generating, by the processor, [output] based on the first [result] and the second [result].
```

**Independent Claim 2 — System:**
```
A system comprising:
a processor; and
a non-transitory computer-readable medium storing instructions that, when executed by the processor, cause the processor to:
[same steps as method claim, adapted to system language].
```

**Independent Claim 3 — Computer-Readable Medium (CRM):**
```
A non-transitory computer-readable medium storing instructions that, when executed by a processor, cause the processor to perform operations comprising:
[same steps as method claim].
```

**Dependent Claims (Claims 4-N)**:
```
The method of claim 1, wherein [specific implementation detail].
```

#### Antecedent Basis Rules (CRITICAL)

Antecedent basis failures are the #1 USPTO rejection reason. Follow these rules strictly:

- **First mention** of any element uses "a" or "an": `"receiving a goal statement"`
- **Subsequent mentions** use "the" or "said": `"comparing the goal statement"`
- **Never** introduce a new element with "the" — if "the score" appears, "a score" must appear earlier
- **Every element** in a dependent claim must trace back to an element in the claim it depends on
- **Consistent terminology** — once you call it "goal statement", never switch to "objective text"

#### Forbidden Language

Do NOT use these phrases anywhere in claims or specification:

| Forbidden | Why | Use Instead |
|-----------|-----|-------------|
| "the invention" | Limits claim scope during prosecution | "the disclosed method", "the system", or "in one embodiment" |
| "the present invention" | Same — courts interpret as applying to ALL claims | "in some implementations" |
| "always", "never", "must" | Absolute language limits claims | "in one embodiment", "may" |
| "obvious", "simple", "easily" | Admission against interest for patentability | Remove entirely |
| "important", "critical", "key" | Implies other features are non-essential | Remove or rephrase |

Aim for:
- 3 independent claims (method + system + CRM triad)
- 5-10 dependent claims covering specifics per independent claim
- Claims covering key differentiators
- Every element properly introduced with antecedent basis

### Step 7: Prior Art Search & Differentiation

Conduct comprehensive prior art search to validate novelty and document differentiation.

#### 6.1 Extract Search Terms

From the innovation, extract:

| Term Type | Description | Example |
|-----------|-------------|---------|
| **Primary** | Core technology concepts | "OKR alignment", "goal scoring" |
| **Secondary** | Implementation details | "multi-dimensional scoring", "semantic similarity" |
| **Domain** | Industry vocabulary | "enterprise goal management", "performance management" |
| **Alternative** | Synonyms | "KPI alignment", "objective scoring" |

#### 6.2 Search Technical Documentation (Context7)

If Context7 MCP is available:

```
1. Resolve library IDs for relevant technologies:
   - context7:resolve-library-id("langchain") → RAG implementations
   - context7:resolve-library-id("dspy") → AI scoring systems

2. Query documentation for similar features:
   - context7:query-docs(libraryId, "alignment scoring")
   - context7:query-docs(libraryId, "multi-dimensional evaluation")
```

#### 6.3 Search Patent Databases

Use web search with these patterns:

| Database | Search Pattern |
|----------|----------------|
| Google Patents | `"[innovation]" site:patents.google.com` |
| USPTO | `"[innovation]" site:patft.uspto.gov` |
| WIPO | `"[innovation]" site:patentscope.wipo.int` |

#### 6.4 Search Academic Literature

| Database | Search Pattern |
|----------|----------------|
| arXiv | `"[innovation]" site:arxiv.org` |
| IEEE | `"[innovation]" site:ieeexplore.ieee.org` |
| ACM | `"[innovation]" site:dl.acm.org` |

#### 6.5 Assess Relevance

For each result found, score relevance:

| Criteria | Score 0-3 | Question |
|----------|-----------|----------|
| Technical Overlap | 0-3 | Same technical approach? |
| Problem Overlap | 0-3 | Solving same problem? |
| Implementation Overlap | 0-3 | Similar implementation? |
| Claims Overlap | 0-3 | Could block our claims? |

**Total Score Interpretation:**
- 0-3: Low relevance — note but no concern
- 4-6: Medium relevance — document differentiation
- 7-9: High relevance — may need to narrow claims
- 10-12: Critical — consult patent counsel

#### 6.6 Document Findings

For each relevant prior art, record:

```json
{
  "name": "Prior Art Name",
  "type": "patent | product | paper | open_source",
  "description": "What it does",
  "limitation": "What it lacks / why insufficient",
  "differentiation": "How our invention differs"
}
```

#### 6.7 If Context7 Unavailable

Provide manual search guidance with links:
- Google Patents: https://patents.google.com
- USPTO: https://patft.uspto.gov
- arXiv: https://arxiv.org
- Google Scholar: https://scholar.google.com

### Step 8: Generate JSON Output

**CRITICAL: You MUST execute the generation script to write files to disk.**

After gathering all information (Steps 1-6), you MUST:

1. Create the disclosure JSON object with all 7 sections
2. Pipe the JSON to the generation script:

```bash
cat << 'EOF' | python3 skills/patent-disclosure/scripts/generate-disclosure.py [INNOVATION-ID] output/disclosures/[INNOVATION-ID]-disclosure.json
{
  "id": "[INNOVATION-ID]",
  "title": "...",
  "title_zh": "...",
  "field_of_invention": ["..."],
  "inventors": ["..."],
  "assignee": "...",
  "abstract": {
    "en": "A computer-implemented method for ... comprising ...",
    "zh_tw": "一種電腦實施的...方法，包含..."
  },
  "problem_statement": {
    "background": ["paragraph 1", "paragraph 2"]
  },
  "summary": {
    "overview": ["paragraph 1", "paragraph 2"],
    "key_innovations": ["innovation 1", "innovation 2"]
  },
  "detailed_description": {
    "system_architecture": "...",
    "components": [
      {"name": "...", "weight": 0.4, "description": "..."}
    ]
  },
  "claims": [
    {"claim_number": 1, "claim_type": "independent", "text": "..."}
  ],
  "prior_art": {
    "reviewed_systems": [
      {"name": "...", "type": "product", "description": "...", "limitation": "..."}
    ],
    "differentiation": "..."
  }
}
EOF
```

3. Verify the file was created:
```bash
ls -la output/disclosures/
```

**DO NOT skip the script execution. The script ensures files are written to disk.**

## Document Structure (7 Sections)

The disclosure document MUST contain exactly these 7 sections — no more, no less:

1. **Metadata** — Title, application number, inventors, assignee, field of invention
2. **Abstract** — Single paragraph (EN max 150 words, TW Chinese max 300 chars). Required by USPTO and TIPO.
3. **Problem Statement** — Background and limitations of existing approaches
4. **Summary of Invention** — High-level solution overview
5. **Detailed Description** — Components, architecture, formulas, algorithms
6. **Claims** — Independent and dependent patent claims (method + system + CRM triad)
7. **Prior Art** — Reviewed systems and differentiation

**DO NOT include:**
- Implementation details
- Quality checklist
- Source code references
- Testing information
- Any sections beyond the 7 listed above

### Step 9: Automatic PDF Generation

After saving JSON, automatically invoke PDF generation:

```bash
# Check if PDF tools are available
./skills/pdf-generator/scripts/check-pdf-tools.sh

# Generate PDF
./skills/pdf-generator/scripts/generate-pdf.sh \
  output/disclosures/[innovation-id]-disclosure.json \
  output/disclosures/[innovation-id]-disclosure.pdf
```

**Output files:**
```
output/disclosures/
├── INV-001-disclosure.json    # Structured data
└── INV-001-disclosure.pdf     # Formatted document
```

**If PDF tools unavailable:**
- JSON is still generated
- Warning message displayed with installation instructions
- User can manually run `/pdf-generator` after installing tools

### Step 10: Post-Generation Review

After the disclosure is generated, recommend the following next steps:

1. **Run `/patent-review [id]`** — Automated quality check scoring 0–100. Flags antecedent basis errors, missing claim triad, spec-claim misalignment, and prior art gaps.
2. **Run `/patent-writer [id]`** — Rewrites claims to proper legal standard, generates missing abstracts, improves spec prose quality, and fixes bilingual content.
3. **Attorney review** — Human patent counsel should review before filing. The automated tools catch mechanical issues, not legal strategy.

## Commands

- `/patent-disclosure [id]` — Generate disclosure for specific innovation (JSON + PDF)
- `/patent-disclosure [id] --no-pdf` — Generate JSON only, skip PDF
- `/patent-disclosure --all` — Generate disclosures for all innovations
- `/patent-disclosure --validate [id]` — Validate existing disclosure

## Example Usage

```
User: /patent-disclosure INV-001