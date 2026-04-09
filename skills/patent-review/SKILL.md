---
name: patent-review
description: Review and score patent disclosure documents for quality before attorney review. Use after generating or improving a disclosure to check for common issues that cause USPTO/TIPO rejections.
---

# Patent Review — Disclosure Quality Scoring

Scores patent disclosure documents on a 0-100 scale and flags issues by severity (CRITICAL, WARNING, INFO) before attorney review.

## When to Use

- After `/patent-disclosure` generates a new disclosure
- After `/patent-writer` improves a disclosure
- Before sending a disclosure to patent counsel
- When validating existing disclosures for completeness

## Input Requirements

1. **Disclosure JSON path** — e.g., `output/disclosures/INV-001-disclosure.json`
2. Or **Innovation ID** — will look for the disclosure in `output/disclosures/`

## Scoring Dimensions

The review scores across 6 dimensions, each weighted:

| Dimension | Weight | What It Checks |
|---|---|---|
| **Claims Quality** | 30% | Triad present, antecedent basis, scope strategy |
| **Abstract Completeness** | 15% | EN present and ≤150 words, TW present and ≤300 chars |
| **Specification Coverage** | 20% | Every claim element described, no orphan elements |
| **Language Compliance** | 15% | No forbidden phrases, consistent terminology |
| **Prior Art** | 10% | At least 2 systems reviewed, differentiation stated |
| **Bilingual Quality** | 10% | TW Chinese uses correct terminology, formal register |

**Score interpretation:**
- **90-100:** Filing-ready — send to attorney
- **70-89:** Good draft — minor issues to address
- **50-69:** Needs work — significant gaps
- **0-49:** Major rewrite needed — use `/patent-writer` first

## Process

### Step 1: Load Disclosure

```
1. Read the disclosure JSON
2. Load patent-writing-guide.md for reference rules
3. Validate JSON structure against disclosure-schema.json
```

If JSON is invalid against schema, report CRITICAL and stop.

### Step 2: Claims Quality Review (30 points)

Check each item and assign points:

**Triad check (10 points):**
- Method claim present: 4 points
- System claim present: 3 points
- CRM claim present: 3 points
- Missing any → CRITICAL flag

**Antecedent basis audit (10 points):**

For each claim:
1. Extract all noun phrases
2. Track first introduction ("a/an") vs subsequent reference ("the/said")
3. Flag any "the [X]" where "a [X]" was never introduced
4. Flag any element in dependent claims not traceable to parent

Scoring:
- 0 violations: 10 points
- 1-2 violations: 7 points + WARNING per violation
- 3-5 violations: 4 points + CRITICAL
- 6+ violations: 0 points + CRITICAL

**Scope and structure (10 points):**
- Independent claims are broad (no implementation specifics): 3 points
- Dependent claims add specificity incrementally: 3 points
- At least 5 dependent claims per independent: 2 points
- Claims cover key differentiators from prior art: 2 points

### Step 3: Abstract Completeness Review (15 points)

**English abstract (8 points):**
- Present: 3 points (missing → CRITICAL)
- ≤ 150 words: 2 points (over → WARNING)
- States what/problem/how: 3 points (check for all three elements)

**Traditional Chinese abstract (7 points):**
- Present: 3 points (missing → CRITICAL for TIPO filings)
- ≤ 300 characters: 2 points (over → WARNING)
- Uses TW terminology: 2 points (mainland terms → WARNING per term)

### Step 4: Specification Coverage Review (20 points)

**Claim-spec alignment (12 points):**

For each element in each independent claim:
1. Search the detailed_description for the element
2. Check that the specification describes how it works
3. Flag any claim element not found in spec → CRITICAL

Scoring:
- All elements covered: 12 points
- 1-2 missing: 8 points + WARNING per miss
- 3+ missing: 4 points + CRITICAL

**Specification quality (8 points):**
- System architecture described: 2 points
- Components have descriptions: 2 points
- Formulas have variable definitions: 2 points
- Alternative embodiments mentioned ("In some implementations..."): 2 points

### Step 5: Language Compliance Review (15 points)

**Forbidden language scan (10 points):**

Scan ALL text fields for:
- "the invention" / "the present invention" → CRITICAL (3 point deduction each)
- "obviously" / "simply" / "easily" → WARNING (2 point deduction each)
- "always" / "never" / "must" (outside claims) → WARNING (1 point deduction each)
- "preferred embodiment" → WARNING (1 point deduction)

**Terminology consistency (5 points):**
- Same element uses same name throughout: 3 points
- No unexplained acronyms: 1 point
- Technical terms defined on first use: 1 point

### Step 6: Prior Art Review (10 points)

- At least 2 prior art systems reviewed: 4 points (fewer → WARNING)
- Each system has a stated limitation: 3 points
- Differentiation summary present: 3 points (missing → WARNING)
- Search terms documented: bonus 0 (no deduction if missing)

### Step 7: Bilingual Quality Review (10 points)

**TW Chinese terminology (6 points):**

Scan all `*_zh` and `zh_tw` fields against the TW term mapping:
- 0 mainland terms: 6 points
- 1-2 mainland terms: 4 points + WARNING per term
- 3+ mainland terms: 2 points + CRITICAL

**Chinese quality (4 points):**
- Uses Traditional characters (繁體): 2 points (Simplified → CRITICAL)
- Formal register (書面語): 2 points

### Step 8: Generate Score Report

Output a structured report:

```
====================================
PATENT REVIEW — INV-001
====================================

SCORE: 78 / 100  [GOOD DRAFT — minor issues to address]

DIMENSION BREAKDOWN:
  Claims Quality:        22 / 30
  Abstract:              12 / 15
  Specification:         18 / 20
  Language:              12 / 15
  Prior Art:              8 / 10
  Bilingual:              6 / 10

------------------------------------
CRITICAL ISSUES (must fix):
------------------------------------
[C1] Missing system claim (Independent Claim 2)
     → Run /patent-writer INV-001 to generate claim triad

[C2] Antecedent basis: Claim 4 references "the threshold"
     but no "a threshold" appears in Claim 1
     → Add "a predefined threshold" to Claim 1 step (c)

------------------------------------
WARNINGS (should fix):
------------------------------------
[W1] English abstract is 163 words (limit: 150)
     → Trim to under 150 words

[W2] Specification: "scope-aware retrieval" in Claim 1
     not described in detailed_description
     → Add section describing scope-aware retrieval

[W3] TW Chinese: found "算法" — should be "演算法"
     → Replace in abstract.zh_tw

------------------------------------
INFO:
------------------------------------
[I1] 6 dependent claims — consider adding more for
     stronger protection (target: 8-10 per independent)

[I2] No alternative embodiments section — adding
     "In some implementations..." variations strengthens spec

====================================
RECOMMENDATION: Fix 2 critical issues, then re-run review
====================================
```

### Step 9: Suggest Fixes

For each CRITICAL and WARNING issue, provide:
1. **What** — the specific problem
2. **Where** — exact location in the JSON (field path)
3. **How** — concrete fix or command to run
4. **Why** — what happens if not fixed (rejection risk)

## Commands

- `/patent-review [id]` — Full review of disclosure
- `/patent-review [id] --claims-only` — Only review claims
- `/patent-review [id] --score-only` — Output score without details
- `/patent-review --all` — Review all disclosures in output/disclosures/

## Integration with Other Skills

```
/patent-disclosure INV-001    → Generate draft disclosure
/patent-review INV-001        → Score and identify issues
/patent-writer INV-001        → Fix identified issues
/patent-review INV-001        → Re-score to verify fixes
/patent-submission INV-001    → Generate presentation once score ≥ 80
```
