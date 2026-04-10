# Quality Scoring Rubric (0-100)

Score the disclosure across 6 dimensions after generation:

| Dimension | Weight | Check |
|-----------|--------|-------|
| Claims Quality | 30% | Triad present, antecedent basis, scope |
| Abstract | 15% | EN ≤150 words, TW ≤300 chars |
| Specification | 20% | Every claim element described in spec |
| Language | 15% | No forbidden phrases, consistent terms |
| Prior Art | 10% | ≥2 systems reviewed, differentiation |
| Bilingual | 10% | TW terminology correct, Traditional chars |

## Claims (30 pts)

- Triad (10): method (4) + system (3) + CRM (3)
- Antecedent basis (10): 0 violations=10, 1-2=7, 3-5=4, 6+=0
- Scope/structure (10): broad independents (3), specific dependents (3), ≥5 deps per indep (2), covers differentiators (2)

## Abstract (15 pts)

- English (8): present (3), ≤150 words (2), what/problem/how (3)
- TW Chinese (7): present (3), ≤300 chars (2), TW terminology (2)

## Specification (20 pts)

- Claim-spec alignment (12): all elements covered
- Quality (8): architecture (2), components (2), formulas (2), embodiment variations (2)

## Language (15 pts)

- Forbidden language (10): "the invention"/"the present invention" (−3 each CRITICAL), "obviously"/"simply" (−2 each), "always"/"never"/"must" (−1), "preferred embodiment" (−1)
- Terminology consistency (5): same terms (3), no unexplained acronyms (1), terms defined (1)

## Prior Art (10 pts)

- ≥2 systems reviewed (4)
- Each has limitation (3)
- Differentiation summary (3)

## Bilingual (10 pts)

- TW terminology (6): 0 mainland (6), 1-2 (4), 3+ (2)
- Chinese quality (4): Traditional (2), formal register (2)

## Score Interpretation

- 90-100: Filing-ready
- 70-89: Good draft — minor fixes
- 50-69: Needs work — significant gaps
- 0-49: Major issues

## Output Format

```
====================================
QUALITY SCORE — [ID]
====================================

SCORE: XX / 100  [INTERPRETATION]

DIMENSION BREAKDOWN:
  Claims Quality:        XX / 30
  Abstract:              XX / 15
  Specification:         XX / 20
  Language:              XX / 15
  Prior Art:             XX / 10
  Bilingual:             XX / 10

ISSUES FOUND:
  [C1] (CRITICAL) description → fix
  [W1] (WARNING) description → fix
  [I1] (INFO) description → suggestion
====================================
```
