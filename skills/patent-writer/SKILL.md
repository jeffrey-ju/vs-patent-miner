---
name: patent-writer
description: Rewrite and improve patent disclosure documents to legal filing standard. Use after generating a disclosure with /patent-disclosure, or when claims, abstracts, or specification prose need quality improvement.
---

# Patent Writer — Disclosure Quality Improvement

Rewrites patent disclosure documents to proper legal standard. Fixes claims, generates missing abstracts, improves specification prose, and corrects bilingual content.

## When to Use

- After `/patent-disclosure` generates a draft that needs polishing
- When claims lack the method/system/CRM triad
- When abstracts are missing or poorly written
- When specification prose contains forbidden language
- When Traditional Chinese content uses mainland terminology

## Input Requirements

1. **Disclosure JSON path** — e.g., `output/disclosures/INV-001-disclosure.json`
2. Or **Innovation ID** — will look for the disclosure in `output/disclosures/`

## Process

### Step 1: Load and Assess

```
1. Read the disclosure JSON
2. Load the patent-writing-guide from skills/patent-disclosure/references/patent-writing-guide.md
3. Identify what needs fixing (run a quick gap analysis)
```

Produce a brief assessment:
```
ASSESSMENT for INV-001:
- Abstract: MISSING / present (EN: X words, TW: X chars)
- Claims: N independent, M dependent
  - Method claim: YES/NO
  - System claim: YES/NO
  - CRM claim: YES/NO
- Antecedent basis: X violations found
- Forbidden language: X instances found
- TW Chinese: X mainland terms detected
```

### Step 2: Generate or Rewrite Abstract

If abstract is missing or inadequate:

**English abstract:**
- Read Claim 1 (method claim) and the summary section
- Write a single paragraph, max 150 words
- Must state: what it is, what problem it solves, how it works
- Use the same terminology as Claim 1
- Do NOT use "the invention", "is disclosed", "this disclosure"

**Traditional Chinese abstract:**
- Translate the English abstract
- Use TIPO-standard terminology from the writing guide term mapping table
- Max 300 characters
- Formal register (書面語)
- Verify every technical term against the TW term mapping

### Step 3: Rewrite Claims to Triad Standard

If the disclosure lacks the full method/system/CRM triad:

1. **Identify the core inventive steps** from the existing claims
2. **Write Method Claim** (Independent Claim 1):
   - Preamble: "A computer-implemented method for [function], comprising:"
   - Steps as gerund phrases with "by a processor" attribution
   - Final step produces the key output
3. **Write System Claim** (Independent Claim 2):
   - Preamble: "A system comprising: a processor; and a non-transitory computer-readable medium..."
   - Same inventive steps adapted to system language
4. **Write CRM Claim** (Independent Claim 3):
   - Preamble: "A non-transitory computer-readable medium storing instructions..."
   - Same inventive steps
5. **Renumber dependent claims** starting from Claim 4
   - Each dependent claim references the correct parent
   - Duplicate dependents for system and CRM claims where applicable

### Step 4: Fix Antecedent Basis

For every claim in the disclosure:

1. Extract all noun phrases
2. Check that first mention uses "a" or "an"
3. Check that subsequent mentions use "the" or "said"
4. Check that dependent claims only reference elements from their parent chain
5. Fix any violations

**Example fix:**
```
BEFORE (violation): "...comparing the alignment score with the threshold..."
       (neither "alignment score" nor "threshold" was introduced)

AFTER  (fixed): "...comparing a computed alignment score with a predefined threshold..."
```

### Step 5: Remove Forbidden Language

Scan the entire disclosure (all sections) for forbidden phrases:

| Find | Replace with |
|------|-------------|
| "the invention" | "the disclosed method" or "the system" |
| "the present invention" | "in some implementations" |
| "obviously" / "simply" / "easily" | Remove entirely |
| "important" / "critical" / "key" (as adjectives) | Remove or rephrase neutrally |
| "always" / "never" / "must" | "in one embodiment" / "may" / "can" |
| "preferred embodiment" | "in one embodiment" |

### Step 6: Fix Traditional Chinese Content

Scan all Chinese text fields (`title_zh`, `abstract.zh_tw`, any bilingual content):

1. Load the TW term mapping from `references/patent-writing-guide.md`
2. Check every technical term against the mapping
3. Replace any Simplified Chinese or mainland terminology with TW equivalents
4. Verify character set is Traditional (繁體), not Simplified (简体)

**Common fixes:**
- 算法 → 演算法
- 软件 → 軟體
- 服务器 → 伺服器
- 数据库 → 資料庫
- 信息 → 資訊
- 接口 → 介面
- 缓存 → 快取

### Step 7: Improve Specification Prose

Review the `summary` and `detailed_description` sections:

1. Ensure every element from claims appears in the specification
2. Add "In some implementations..." variations for flexibility
3. Remove value judgments ("superior", "optimal", "best")
4. Ensure consistent terminology between claims and spec
5. Check that formulas have all variables defined

### Step 8: Write Updated Disclosure

Write the improved disclosure JSON back to disk:

```bash
cat << 'EOF' | python3 skills/patent-disclosure/scripts/generate-disclosure.py [INNOVATION-ID] output/disclosures/[INNOVATION-ID]-disclosure.json
{ ... improved disclosure ... }
EOF
```

### Step 9: Generate Change Summary

Output a summary of all changes made:

```
CHANGES APPLIED to INV-001:
- [ADDED] Abstract (EN: 142 words, TW: 267 chars)
- [ADDED] System claim (Claim 2) and CRM claim (Claim 3)
- [FIXED] 4 antecedent basis violations in claims
- [FIXED] 3 instances of "the invention" → "the disclosed method"
- [FIXED] 2 mainland Chinese terms → TW equivalents
- [IMPROVED] Specification prose in 2 sections
- Claims: 3 independent + 8 dependent (was: 1 independent + 5 dependent)
```

## Commands

- `/patent-writer [id]` — Improve disclosure for specific innovation
- `/patent-writer [id] --claims-only` — Only rewrite claims
- `/patent-writer [id] --abstract-only` — Only generate/fix abstract
- `/patent-writer [id] --dry-run` — Show changes without applying

## Example Usage

```
User: /patent-writer INV-001