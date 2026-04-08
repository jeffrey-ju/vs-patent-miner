# Codebase Scan Patterns

## File Priority Order

When scanning a codebase, prioritize files in this order:

### 1. Documentation (Highest Priority)
```
README.md
README*.md
ARCHITECTURE.md
docs/**/*.md
*.md (root level)
```

**Why**: Documentation often explicitly describes innovations and unique features.

### 2. Core Business Logic
```
# Python
src/**/service*.py
src/**/domain/**/*.py
src/**/*_service.py
src/**/*_workflow*.py

# TypeScript/JavaScript
lib/**/*.ts
src/services/**/*.ts
src/domain/**/*.ts

# Go
internal/**/*.go
pkg/**/*.go

# Java
src/main/**/service/**/*.java
src/main/**/domain/**/*.java
```

**Why**: Core business logic contains the main innovations.

### 3. AI/ML Modules
```
# Python
**/ai/**/*.py
**/ml/**/*.py
**/models/**/*.py
**/*_model*.py
**/*dspy*.py
**/*langchain*.py

# TypeScript
**/ai/**/*.ts
**/ml/**/*.ts
hooks/use*AI*.ts
```

**Why**: AI modules often contain proprietary algorithms.

### 4. Algorithm Implementations
```
**/*algorithm*.py
**/*scoring*.py
**/*alignment*.py
**/*calculate*.py
**/*evaluate*.py
```

**Why**: Custom algorithms are prime patent candidates.

### 5. API Definitions
```
# Python (FastAPI/Flask)
**/api/**/*.py
**/routes/**/*.py
**/endpoints/**/*.py

# TypeScript (Next.js/Express)
app/api/**/*.ts
pages/api/**/*.ts
routes/**/*.ts
```

**Why**: API designs may reveal unique system architectures.

---

## Code Pattern Recognition

### Pattern 1: Custom Scoring Systems

Look for:
```python
# Weighted scoring
score = (component_a * weight_a) + (component_b * weight_b)

# Multi-dimensional scoring
class ScoreBreakdown:
    dimension_1: float
    dimension_2: float
    composite: float

# Configurable weights
WEIGHT_A = 0.40
WEIGHT_B = 0.40
WEIGHT_C = 0.20
```

### Pattern 2: Hierarchical Traversal

Look for:
```python
# Management chain traversal
def find_in_hierarchy(start_id, max_levels=3):
    current = start_id
    for level in range(max_levels):
        result = check_level(current)
        if result:
            return result
        current = get_parent(current)

# Scope-aware retrieval
SCOPE_WEIGHTS = {
    "team": 1.2,
    "department": 1.0,
    "company": 0.8
}
```

### Pattern 3: State Machines

Look for:
```python
# Explicit state transitions
class Status(Enum):
    DRAFT = "draft"
    SUBMITTED = "submitted"
    APPROVED = "approved"

VALID_TRANSITIONS = {
    Status.DRAFT: [Status.SUBMITTED],
    Status.SUBMITTED: [Status.APPROVED, Status.DRAFT],
}

# Workflow with state checks
def submit(self):
    if self.status != Status.DRAFT:
        raise InvalidTransition()
    self.status = Status.SUBMITTED
```

### Pattern 4: Context-Aware Processing

Look for:
```python
# User context influencing behavior
def process(data, user_context):
    if user_context.role == "manager":
        return process_as_manager(data)
    return process_default(data)

# Scope-based filtering
def get_documents(user):
    docs = []
    docs.extend(get_team_docs(user.team_id))
    docs.extend(get_dept_docs(user.department))
    docs.extend(get_company_docs())
    return apply_scope_weights(docs)
```

### Pattern 5: Language-Aware Processing

Look for:
```python
# CJK detection
def is_chinese(text):
    chinese_chars = len(re.findall(r'[\u4e00-\u9fff]', text))
    return (chinese_chars / len(text)) > 0.3

# Language-specific patterns
ENGLISH_PATTERNS = [r'\d+%', r'\$\d+']
CHINESE_PATTERNS = [r'[個件次人]', r'提升|增加|達成']
```

### Pattern 6: Progressive Streaming

Look for:
```typescript
// SSE handling
const eventSource = new EventSource(url);
eventSource.onmessage = (event) => {
    const data = JSON.parse(event.data);
    if (data.type === 'token') {
        appendToken(data.content);
    }
};

// Streaming state management
const [streamedText, setStreamedText] = useState('');
const [isStreaming, setIsStreaming] = useState(false);
```

---

## Red Flags (Likely Not Patentable)

### Common Library Usage
```python
# Standard library usage - not patentable
from sklearn.metrics import cosine_similarity
result = cosine_similarity(vec_a, vec_b)

# vs Custom implementation - potentially patentable
def weighted_similarity(vec_a, vec_b, scope_weights):
    base = cosine_similarity(vec_a, vec_b)
    return apply_scope_weights(base, scope_weights)
```

### Standard CRUD Operations
```python
# Standard CRUD - not patentable
def create_user(data):
    user = User(**data)
    db.session.add(user)
    db.session.commit()
```

### Common Design Patterns
```python
# Standard singleton - not patentable
class Singleton:
    _instance = None
    
    @classmethod
    def get_instance(cls):
        if cls._instance is None:
            cls._instance = cls()
        return cls._instance
```

---

## Scan Output Format

After scanning, produce:

```json
{
  "scan_summary": {
    "total_files": 150,
    "files_with_innovations": 12,
    "innovation_candidates": 8
  },
  "priority_files": [
    {
      "path": "src/ai/alignment.py",
      "reason": "Multi-dimensional scoring system",
      "innovation_ids": ["INV-001"]
    }
  ],
  "skip_reasons": [
    {
      "path": "src/utils/helpers.py",
      "reason": "Standard utility functions"
    }
  ]
}
```
