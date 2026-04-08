# Prior Art Search Guide

## Search Strategy

### Phase 1: Keyword Extraction

From the innovation, extract:

1. **Core Concept** — What is the main idea?
2. **Technical Method** — How is it implemented?
3. **Application Domain** — Where is it used?
4. **Unique Elements** — What makes it novel?

### Phase 2: Database Selection

| Innovation Type | Primary Databases |
|-----------------|-------------------|
| AI/ML | arXiv, Google Patents, IEEE |
| Software Architecture | USPTO, ACM DL |
| UI/UX | Design patents, HCI papers |
| Data Processing | Database patents, VLDB papers |
| Security | USENIX, IEEE S&P |

### Phase 3: Search Execution

#### Google Patents Syntax

```
# Basic search
"multi-dimensional scoring" OKR

# With classification
"multi-dimensional scoring" CPC:G06Q10/0639

# Specific assignee
"alignment scoring" assignee:Microsoft

# Date range
"goal alignment" after:2020-01-01
```

#### arXiv Search

```
# Title search
ti:"multi-dimensional" AND ti:"scoring"

# Abstract search
abs:"OKR" AND abs:"alignment"

# Category filter
cat:cs.AI AND "goal scoring"
```

### Phase 4: Relevance Assessment

For each result, assess:

| Criteria | Score | Description |
|----------|-------|-------------|
| Technical Overlap | 0-3 | Same technical approach? |
| Problem Overlap | 0-3 | Solving same problem? |
| Implementation Overlap | 0-3 | Similar implementation? |
| Claims Overlap | 0-3 | Could block our claims? |

**Total Score:**
- 0-3: Low relevance — note but no concern
- 4-6: Medium relevance — document differentiation
- 7-9: High relevance — may need to narrow claims
- 10-12: Critical — significant overlap, consult counsel

### Phase 5: Differentiation Documentation

For each relevant prior art, document:

1. **What it does** — Brief description
2. **What it lacks** — Limitations
3. **How we differ** — Our unique contribution
4. **Why ours is better** — Improvement

---

## Common Search Terms by Category

### AI/ML Innovations

```
- machine learning scoring system
- neural network evaluation
- embedding similarity
- semantic alignment
- multi-dimensional classification
- weighted ensemble scoring
- transformer-based assessment
```

### Data Processing

```
- hierarchical data retrieval
- scope-aware indexing
- context-sensitive caching
- document similarity ranking
- vector database search
- RAG implementation
```

### System Architecture

```
- workflow orchestration
- state machine transition
- event-driven notification
- microservice pattern
- API gateway design
```

### UI/UX

```
- progressive rendering
- streaming user interface
- real-time visualization
- interactive dashboard
- accessibility pattern
```

---

## Context7 Integration

### Resolving Library IDs

```bash
# Find library ID
context7:resolve-library-id
  libraryName: "langchain"
  query: "RAG retrieval augmented generation"

# Returns: /langchain-ai/langchain
```

### Querying Documentation

```bash
# Search for similar implementations
context7:query-docs
  libraryId: "/langchain-ai/langchain"
  query: "document retrieval with scoring"
```

### Checking for Existing Solutions

1. Identify technologies used in innovation
2. Resolve Context7 IDs for each
3. Search for similar features
4. Document any overlap

---

## Red Flags in Prior Art

### Blocking Patents

Watch for patents that:
- Cover the exact method
- Have broad claims in the same space
- Are from major competitors
- Were recently filed (may have continuations)

### Academic Prior Art

Watch for papers that:
- Describe the same algorithm
- Were published before your implementation
- Are well-cited in the field

### Commercial Products

Watch for products that:
- Advertise similar features
- Have patents in the space
- Might file continuation patents

---

## Documentation Template

```markdown
## Prior Art: [Innovation Title]

### Search Summary
- **Date:** YYYY-MM-DD
- **Databases searched:** [list]
- **Terms used:** [list]

### Relevant Patents

#### [Patent Title]
- **Number:** US12345678
- **Assignee:** Company Name
- **Relevance:** High/Medium/Low
- **Overlap:** [description]
- **Differentiation:** [how we differ]

### Relevant Papers

#### [Paper Title]
- **Authors:** [names]
- **Venue:** Conference/Journal YYYY
- **Relevance:** High/Medium/Low
- **Overlap:** [description]
- **Differentiation:** [how we differ]

### Commercial Products

#### [Product Name]
- **Company:** Company Name
- **Relevance:** High/Medium/Low
- **Overlap:** [description]
- **Differentiation:** [how we differ]

### Assessment

**Novelty Score:** X/100
**Confidence:** High/Medium/Low
**Recommendation:** [proceed/revise claims/consult counsel]
```
