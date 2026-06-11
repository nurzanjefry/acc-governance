# Agent Interface Specification — Contract for Interchangeable Agents

**Purpose:** Define input/output contracts so agents can be swapped without breaking orchestration.

> **Note:** `agent-registry.json` referenced in the Substitution Logic and Agent Lifecycle sections is a forward-looking design — it does not currently exist as a live file. The registry-driven dispatch pattern is the target architecture; current dispatch is PM-manual.

**Version:** 1.0  
**Last Updated:** 2026-06-11

---

## Overview

Every agent (Claude, human, executor) must follow this interface contract:
- Same input schema (all agents receive same briefing format)
- Same output schema (all agents return same JSON structure)
- Same error handling (timeouts, crashes, invalid output)

This enables **agent interchangeability**: swap Claude for human, or one reviewer for another, without code changes.

---

## Core Interface Contract

### Input Schema

Every agent receives:
```json
{
  "project": "<project-name>",
  "phase": "02-spec",
  "work_item": {
    "id": "spec-001",
    "title": "Data Model Specification",
    "description": "..."
  },
  "brief": {
    "task": "Review data model specification for ACID compliance, constraint validation, multi-tenancy isolation",
    "deliverable": "findings.md with blockers, majors, minors categorized",
    "deadline": "2026-06-15T15:00:00Z"
  },
  "context": {
    "phase": "02-spec",
    "profile": "standard",
    "applicable_adrs": ["adr-001", "adr-003"],
    "prior_deliverables": ["01-define/product-definition.md"],
    "constraints": [
      "Compliance requirement (if applicable)",
      "Critical path (if applicable)",
      "Multi-tenant isolation (if applicable)"
    ]
  }
}
```

### Output Schema (All Agents)

Every agent must return:
```json
{
  "status": "success",
  "deliverables": [
    "path/to/findings.md"
  ],
  "session_log": "path/to/session/log.md",
  "error": null,
  "duration_seconds": 1200,
  "tokens_used": 3456,
  "summary": "5 blockers found: missing company_id, no encryption for PII, api versioning unclear"
}
```

### Required Fields

| Field | Type | Required | Description | Example |
|---|---|---|---|---|
| **status** | enum | Yes | success \| partial \| failed | "success" |
| **deliverables** | array | Yes | File paths created by agent | ["findings.md"] |
| **session_log** | string | Yes | Path to session log (for debugging) | ".claude/logs/spec-001-session.md" |
| **error** | string \| null | Yes | Error message if status != success | null or "Agent timeout" |
| **duration_seconds** | number | Yes | Time spent (in seconds) | 1200 |
| **tokens_used** | number | Yes | API tokens consumed (if applicable) | 3456 |
| **summary** | string | Yes | One-line summary of what agent did | "5 blockers found" |

### Timeout Specification

- **Timeout:** 4 hours (14400 seconds) by default
- **Per agent:** Can override if specialist needs more time
- **Fallback:** If timeout exceeded, escalate to fallback agent
- **Retry:** After timeout, can retry once before escalation

---

## Agent Types & Roles

### Type 1: Producer Agents

**Role:** Create deliverables (specs, code, designs)

**Input:** Brief + context  
**Output:** Deliverable files (spec.md, code.py, etc.) + session log

**Example:** spec-author

```json
{
  "role": "Produce Phase 2 specification",
  "input": {
    "brief": "Write data model spec for receipt table, order table, customer table. Include schema, constraints, indexes, rationale.",
    "context": { "phase": "02-spec", "constraints": ["PCI-DSS", "ACID required"] }
  },
  "output": {
    "status": "success",
    "deliverables": ["02-spec/data-model.md"],
    "session_log": ".claude/logs/spec-author-02-spec-session.md"
  }
}
```

### Type 2: Reviewer Agents

**Role:** Review deliverables; find blockers/majors/minors

**Input:** Brief + deliverable to review  
**Output:** Findings (blockers, majors, minors) + session log

**Example:** data-model-reviewer

```json
{
  "role": "Review database schema",
  "input": {
    "brief": "Review 02-spec/data-model.md. Check: ACID compliance, constraint validation, multi-tenancy isolation, PCI-DSS compliance.",
    "context": { "phase": "02-spec", "constraints": ["Finance-critical", "PCI-DSS"] }
  },
  "output": {
    "status": "success",
    "deliverables": ["findings/spec-001-findings.md"],
    "summary": "5 blockers: missing company_id, no PII encryption, ..."
  }
}
```

### Type 3: Executor Agents

**Role:** Execute operations (git, build, deploy)

**Input:** Brief + context  
**Output:** Execution results + session log

**Example:** git-author

```json
{
  "role": "Git commit and push",
  "input": {
    "brief": "git commit -m 'docs(spec-001): Add data model spec'; git push origin feature/spec-001",
    "context": { "project": "tallybite", "branch": "feature/spec-001" }
  },
  "output": {
    "status": "success",
    "summary": "Committed a1b2c3d; pushed to origin/feature/spec-001",
    "duration_seconds": 30
  }
}
```

---

## Interchangeability Rules

### Two agents are interchangeable if:

1. ✅ **Same role** (both producer, both reviewer, or both executor)
2. ✅ **Same input schema** (accept same brief format)
3. ✅ **Same output schema** (return findings in same format)
4. ✅ **Same specialization domain** (both understand databases, OR both understand security)

### Example: Interchangeable

```
data-model-reviewer (Claude) ↔ human-dba (Expert)
- Both roles: Reviewer
- Both input: Review data model spec
- Both output: Findings with blockers
- Both specialization: Database schema
→ INTERCHANGEABLE
```

### Example: NOT Interchangeable

```
spec-author (Producer) ↔ data-model-reviewer (Reviewer)
- Different roles: One produces, one reviews
- Different input: One writes spec, one reviews spec
- Different output: One returns deliverable, one returns findings
→ NOT INTERCHANGEABLE
```

---

## Fallback, Error Handling & SLA

See `.claude/docs/agent-fallback.md` for: fallback chain, status codes, error reporting format, substitution logic, and SLA table.

---

## Lifecycle, Examples & Testing

See `.claude/docs/agent-lifecycle.md` for: agent development/operation/evolution lifecycle, interchangeability examples (Claude→Human, cost optimization, version upgrade), and how to test interchangeability.
