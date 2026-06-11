# project.json Schema

Every project governed by acc-governance must have a `project.json` at its root. This is the project's identity file and framework link.

## Schema

```json
{
  "type": "project",
  "name": "string — project name",
  "domain": "string — business domain (e.g. Finance, Healthcare)",
  "problem_statement": "string — one sentence",
  "framework_version": "string — version of acc-governance used (e.g. 1.0)",
  "framework_source": "string — path or URL to acc-governance (standalone projects only)",
  "placement": "embedded | standalone",
  "created": "string — ISO date (YYYY-MM-DD)",
  "current_phase": "integer — 1 through 5"
}
```

## Examples

**Embedded project** (`acc-governance/projects/my-app/project.json`):
```json
{
  "type": "project",
  "name": "my-app",
  "domain": "Finance",
  "problem_statement": "Automate invoice reconciliation for SMEs.",
  "framework_version": "1.0",
  "placement": "embedded",
  "created": "2026-06-11",
  "current_phase": 1
}
```

**Standalone project** (`~/my-app/project.json`):
```json
{
  "type": "project",
  "name": "my-app",
  "domain": "Finance",
  "problem_statement": "Automate invoice reconciliation for SMEs.",
  "framework_version": "1.0",
  "framework_source": "C:/Users/nurza/acc-governance",
  "placement": "standalone",
  "created": "2026-06-11",
  "current_phase": 1
}
```

## Rules

- `framework_source` is required for standalone projects, omitted for embedded.
- `current_phase` is updated by the PM at each phase transition.
- `framework_version` records which version of acc-governance this project started from — used to surface available upgrades.
- This file is created by the PM during project initialization. The Owner does not edit it directly.
- **If `project.json` already exists, the PM must read it first, identify only missing fields, confirm the delta with the Owner, and merge — never overwrite.**

## Companion File: project-context.md

Every project must also have a `project-context.md` at its root alongside `project.json`.

`project.json` is machine-readable identity. `project-context.md` is human+agent-readable context — it tells agents what already exists so they don't start from scratch.

Created by the PM when linking or initializing. Updated by the PM at each phase transition.

See template at `01-define/project-context-template.md`.
