# Test Plan — Template

**Purpose:** Define the testing strategy so every critical path is covered before ship.

## Sections to Include

### 1. Scope
What is being tested? What is explicitly out of scope?

### 2. Test Levels

#### Unit Tests
- Coverage target: >80%
- What to test: business logic, utility functions, edge cases
- Framework:

#### Integration Tests
- Coverage target: >50% of API endpoints
- What to test: database reads/writes, external service calls
- Framework:

#### E2E Tests
- Happy path(s) to cover:
  1. [flow name] — steps: ...
- Error cases to cover:
  1. [error case] — expected behavior: ...
- Framework:

### 3. Manual Test Checklist
Steps a human must verify before each release.
- [ ] Step 1
- [ ] Step 2

### 4. Performance Baselines
| Endpoint / Operation | Target (p95) | Acceptable Max |
|----------------------|--------------|----------------|
| | | |

### 5. Regression Suite
What existing functionality must not break?
- [ ] Feature 1
- [ ] Feature 2

---

**After completing this, move to tracking-plan.md and deployment.md.**
