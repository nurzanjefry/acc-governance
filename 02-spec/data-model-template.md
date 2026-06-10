# Data Model — Template

**Purpose:** Design your database schema and entity relationships.

## Core Entities

List your primary entities and their fields.

### Entity 1: [Name]

| Field | Type | Constraints | Purpose |
|---|---|---|---|
| id | UUID | PRIMARY KEY | Unique identifier |
| name | TEXT | NOT NULL | [purpose] |
| created_at | TIMESTAMP | NOT NULL | Audit trail |

### Entity 2: [Name]
[Similar structure]

## Relationships

How do entities relate to each other?

```
Entity1 (1) ─→ (N) Entity2
  ↓
Entity3
```

Document foreign keys, cascading rules, and multi-tenancy isolation (if applicable).

## Constraints & Indexes

- Primary Keys: [list]
- Foreign Keys: [list with cascading rules]
- UNIQUE constraints: [list]
- CHECK constraints: [list]
- Indexes: [list for performance]

## Design Decisions

- How will you handle multi-tenancy? (if needed)
- How will you audit changes? (immutable log?)
- How will you handle soft-deletes vs. hard-deletes?

---

**After data model, move to tech-spec.md to document API design.**
