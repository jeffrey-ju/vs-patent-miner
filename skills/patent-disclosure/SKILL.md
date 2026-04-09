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

Write filing-quality abstracts for both English and Traditional Chinese (繁體中文).

#### English Abstract Process (USPTO 37 CFR 1.72(b))

1. **Read Claim 1** (method claim) and the summary section
2. **Write a single paragraph**, maximum 150 words, that states:
   - What the invention is
   - What problem it solves
   - How it works (key technical steps)
3. **Use the same terminology as Claim 1** — every technical term in the abstract must match the claim language exactly
4. **Verify word count** — must be ≤ 150 words
5. **Scan for forbidden phrases** and remove:
   - "the invention", "the present invention"
   - "is disclosed", "this disclosure"
   - "obviously", "simply", "easily"

#### Traditional Chinese Abstract Process (TIPO)

1. **Translate the English abstract** into Traditional Chinese
2. **Apply the TW term mapping** — replace any mainland terminology:

   | Mainland (禁用) | Taiwan (使用) |
   |-----------------|--------------|
   | 算法 | 演算法 |
   | 软件 | 軟體 |
   | 服务器 | 伺服器 |
   | 数据库 | 資料庫 |
   | 信息 | 資訊 |
   | 接口 | 介面 |
   | 缓存 | 快取 |

3. **Verify formal register** (書面語) — no colloquial expressions
4. **Verify character count** — must be ≤ 300 characters
5. **Verify character set** is Traditional (繁體), not Simplified (简体)

#### Abstract Template

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

#### Specification Prose Quality Rules

Apply these rules while writing the detailed description to ensure filing-quality prose:

1. **Claim-spec alignment** — every element mentioned in any claim MUST appear in the detailed description with a full explanation of how it works. If a claim says "computing a weighted alignment score", the spec must describe the weighting mechanism.
2. **Embodiment variations** — include "In some implementations..." or "In one embodiment..." variations for key features to provide flexibility during prosecution.
3. **No value judgments** — remove "superior", "optimal", "best", "ideal", "perfect". Use neutral language describing what the system does, not how good it is.
4. **Terminology consistency** — use the exact same terms as the claims throughout the spec. If the claim says "goal statement", never switch to "objective text" or "target description" in the spec.
5. **Formula completeness** — every formula must define all variables with units and ranges where applicable.

### Step 6: Draft Claims

Generate filing-quality patent claims following the method/system/CRM triad. See `references/patent-writing-guide.md` for the full writing guide.

#### 6.1 Identify Core Inventive Steps

Before writing any claims, extract the core inventive steps from the code analysis:

1. List the 3-6 key technical steps that make this innovation novel
2. Order them logically (input → processing → output)
3. Identify which steps differentiate from prior art
4. These steps form the basis for all three independent claims

#### 6.2 Write Method Claim (Independent Claim 1)

Write the method claim first — it serves as the foundation for the other two:

```
A computer-implemented method for [function], comprising:
(a) receiving, by a processor, [first input];
(b) computing, by the processor, a first [result] by [technical step];
(c) determining, by the processor, a second [result] based on [technical step]; and
(d) generating, by the processor, [output] based on the first [result] and the second [result].
```

- Preamble: "A computer-implemented method for [function], comprising:"
- Each step as a gerund phrase with "by a processor" attribution
- Final step produces the key output
- Keep independent claims broad — no implementation specifics

#### 6.3 Write System Claim (Independent Claim 2)

Adapt the method claim to system language:

```
A system comprising:
a processor; and
a non-transitory computer-readable medium storing instructions that, when executed by the processor, cause the processor to:
[same steps as method claim, adapted to system language].
```

#### 6.4 Write CRM Claim (Independent Claim 3)

Adapt the method claim to computer-readable medium:

```
A non-transitory computer-readable medium storing instructions that, when executed by a processor, cause the processor to perform operations comprising:
[same steps as method claim].
```

#### 6.5 Write Dependent Claims (Claims 4-N)

```
The method of claim 1, wherein [specific implementation detail].
```

- Each dependent claim adds one specific implementation detail
- Duplicate relevant dependents for system claim (e.g., "The system of claim 2, wherein...") and CRM claim (e.g., "The non-transitory computer-readable medium of claim 3, wherein...")
- Target 5-10 dependent claims per independent claim
- Cover key differentiators from prior art

#### 6.6 Renumber All Claims

After drafting, renumber sequentially:
- Claim 1: Method (independent)
- Claim 2: System (independent)
- Claim 3: CRM (independent)
- Claims 4-N: Dependent claims referencing the correct parent

#### 6.7 Antecedent Basis Audit (CRITICAL — DO NOT SKIP)

Antecedent basis failures are the #1 USPTO rejection reason. After drafting all claims, run this audit:

1. **For each claim**, extract every noun phrase
2. **Check first mention** uses "a" or "an": `"receiving a goal statement"`
3. **Check subsequent mentions** use "the" or "said": `"comparing the goal statement"`
4. **Check dependent claims** — every element must trace back to an element in the parent claim chain
5. **Fix any violations** before proceeding

**Example fix:**
```
BEFORE (violation): "...comparing the alignment score with the threshold..."
       (neither "alignment score" nor "threshold" was introduced)

AFTER  (fixed): "...comparing a computed alignment score with a predefined threshold..."
```

**Consistency rule:** Once you call it "goal statement", never switch to "objective text" — same term throughout all claims and specification.

#### 6.8 Forbidden Language Scan (MANDATORY)

After drafting all claims AND specification text, scan ALL text fields and apply replacements:

| Find | Replace with |
|------|-------------|
| "the invention" | "the disclosed method" or "the system" |
| "the present invention" | "in some implementations" |
| "obviously" / "simply" / "easily" | Remove entirely |
| "important" / "critical" / "key" (as adjectives) | Remove or rephrase neutrally |
| "always" / "never" / "must" | "in one embodiment" / "may" / "can" |
| "preferred embodiment" | "in one embodiment" |

This scan covers claims, abstract, problem statement, summary, and detailed description — every text field in the disclosure.

#### Targets

- 3 independent claims (method + system + CRM triad)
- 5-10 dependent claims covering specifics per independent claim
- Claims covering key differentiators
- Every element properly introduced with antecedent basis
- Zero forbidden language instances

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

1. **Run `/patent-review [id]`** — Automated quality check scoring 0–100. Flags any remaining antecedent basis errors, spec-claim misalignment, or prior art gaps. Target score ≥ 80 before proceeding.
2. **Attorney review** — Human patent counsel should review before filing. The automated tools catch mechanical issues, not legal strategy.

## Commands

- `/patent-disclosure [id]` — Generate disclosure for specific innovation (JSON + PDF)
- `/patent-disclosure [id] --no-pdf` — Generate JSON only, skip PDF
- `/patent-disclosure --all` — Generate disclosures for all innovations
- `/patent-disclosure --validate [id]` — Validate existing disclosure

## Example Usage

```
User: /patent-disclosure INV-001