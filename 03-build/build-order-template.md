# Build Order — Template

**Purpose:** Define the sequence of implementation milestones so nothing is built out of order.

## Sections to Include

### 1. Prerequisites
What must be done before any code is written?
- [ ] Phase 2 spec approved
- [ ] Dev environment set up
- [ ] External service credentials provisioned

### 2. Milestone Sequence

#### Milestone 1: Foundation
- What to build first (database schema, auth, project scaffold)
- Estimated effort:
- Acceptance criteria:

#### Milestone 2: Core Domain Logic
- What business logic comes next
- Estimated effort:
- Acceptance criteria:

#### Milestone 3: API Layer
- Endpoints to implement (reference tech-spec.md)
- Estimated effort:
- Acceptance criteria:

#### Milestone 4: Integration
- External services, third-party APIs
- Estimated effort:
- Acceptance criteria:

#### Milestone 5: Polish & Hardening
- Error handling, edge cases, performance
- Estimated effort:
- Acceptance criteria:

### 3. Dependencies Map
Which milestones block which? (prevents parallel work on dependent items)

### 4. Definition of Done
What does "build complete" mean for this project?
- All exit criteria in 03-build/CLAUDE.md met
- Reviewed and approved by Owner

---

**After completing this, begin Milestone 1 implementation.**
