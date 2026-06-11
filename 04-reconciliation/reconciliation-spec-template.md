# Reconciliation Spec — Template

**Purpose:** Define the core domain logic — matching algorithms, state machines, business rules, and edge cases.

## Sections to Include

### 1. Domain Overview
What is being reconciled or validated? What is the business rule this logic enforces?

### 2. Input / Output Contract
- **Input:** What data enters this logic?
- **Output:** What is produced or mutated?
- **Preconditions:** What must be true before this runs?

### 3. Matching / Processing Algorithm
Step-by-step description of the core algorithm.

```
Step 1: ...
Step 2: ...
Step 3: ...
```

### 4. State Machine (if applicable)
Valid states and transitions.

| From State | Event | To State | Action |
|------------|-------|----------|--------|
| | | | |

### 5. Business Rules
Explicit rules that must hold true. Each rule should be testable.

- Rule 1: [condition] → [outcome]
- Rule 2: [condition] → [outcome]

### 6. Edge Cases
What happens at the boundaries?

| Edge Case | Expected Behavior |
|-----------|-------------------|
| | |

### 7. Audit Trail Requirements
What must be logged for compliance or debugging?
- What is logged:
- When:
- Immutability requirement:

### 8. Error Handling
How are invalid inputs or failed operations handled?

---

**After completing this, validate against Phase 1 product definition and Phase 2 data model.**
