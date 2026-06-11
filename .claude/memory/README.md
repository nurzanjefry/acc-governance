# Memory System Guide

The `.claude/memory/` directory captures reusable cross-session knowledge that helps the PM and agents learn from prior work.

---

## Purpose

**What memory is:**
- Cross-session cache of institutional knowledge
- PM-curated insights from completed phases
- Reusable patterns and anti-patterns
- Human judgment calls and rejection reasons

**What memory is NOT:**
- Not a replacement for PROGRESS.md (audit log) or ADRs (decisions)
- Not agent state (agents remain stateless)
- Not mandatory (framework works without it)

---

## Structure

```
.claude/memory/
├── README.md                    # This file
├── project/
│   ├── domain-insights.md      # Domain patterns discovered
│   └── rejection-log.md        # Why items were reopened
├── agents/
│   ├── reviewer-calibration.md # Common reviewer findings
│   └── producer-briefs.md      # Best practices for agent briefs
└── decisions/
    └── judgment-overrides.md   # Human approved despite concerns
```

---

## File Format

Each memory file uses:
- **Frontmatter** (YAML) — metadata
- **Content** — insights organized by topic
- **Cross-links** — `[[file-references]]` to ADRs, PROGRESS.md

**Template:**
```markdown
---
name: reviewer-calibration
description: Common patterns found by reviewers across phases
type: agent-learning
last_updated: 2026-06-11
---

## [reviewer-name] patterns
- **Pattern name**: Description
- **References**: [[decisions/adr-xxx.md]]
```

---

## When PM Writes to Memory

**Extraction criteria (Step 8: Close-Out):**
- Pattern appears **>2 times** across phases → extract to memory
- Item reopened (rejected) → log to `project/rejection-log.md`
- Human overrides reviewer concern → log to `decisions/judgment-overrides.md`

**PM does NOT write:**
- One-off findings (keep in PROGRESS.md)
- Agent-specific session data (keep in local logs/)
- Duplicate information already in ADRs or GLOSSARY.md

---

## When PM Reads Memory

**Step 0 (Orient):**
- PM reads memory files relevant to current phase
- Reconstructs context faster than re-reading full PROGRESS.md

**Step 4 (Dispatch):**
- PM injects relevant memory snippet into agent brief
- Example: "data-model-reviewer flagged missing company_id in Phase 2"

---

## Agent Access

**Agents are read-only:**
- Receive memory snippets in PM brief
- Never write to memory directly
- Memory is optional context, not mandatory

---

## Ownership

| Actor | Read | Write |
|-------|------|-------|
| PM | ✓ | ✓ |
| Agents | ✓ (via PM brief) | ✗ |
| Owner | ✓ | ✗ (requests cleanup) |

---

## Maintenance

**Cleanup trigger:**
- Owner requests stale memory cleanup
- Phase 5 (ship) complete → archive phase-specific memories

**Growth rate:**
- ~50 lines per memory file
- Grows slowly (extraction threshold: >2 occurrences)

---

## Backward Compatibility

If `.claude/memory/` is missing → framework continues with existing behavior (no memory enhancement).

Memory is an opt-in optimization, not a breaking change.
