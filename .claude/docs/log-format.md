# Log Format — Agent Task Records

Every work item has a log file at `logs/<item-id>.md`. PM owns this file.
Agents never write to it. PM writes BEFORE dispatching and AFTER receiving JSON.

These two records are the recovery point if an agent errors mid-task.

---

## BEFORE Record (PM writes before dispatching agent)

```markdown
## BEFORE — <item-id>

- Agent dispatched: <agent-name>
- Time: <ISO 8601>
- Work item: <item-id> — <title>
- Phase: <01-define | 02-spec | 03-build | 04-reconciliation | 05-test-ship>
- Context files passed:
  - <file-path-1>
  - <file-path-2>
- Expected output files:
  - <file-path>
- Status set: in_progress
```

---

## AFTER Record (PM writes after receiving agent JSON)

```markdown
## AFTER — <item-id>

- Agent: <agent-name>
- Time: <ISO 8601>
- Outcome: completed | failed | partial
- Files written:
  - <file-path>
- References to update (from agent JSON):
  - <parent-doc> → <link location>
- Exit criteria met: yes | no | partial
- Status set: pending_review | failed | needs_revision
- Notes: <any relevant context>
```

---

## ERROR Record (PM writes if agent returns no JSON)

```markdown
## ERROR — <item-id>

- Agent: <agent-name>
- Time detected: <ISO 8601>
- Last known state: BEFORE record at <time>
- What failed: <description or "unknown — no JSON returned">
- Files possibly written: <list if known, or "unknown">
- Recovery suggestion: retry | escalate to Owner | manual inspection
- Status set: failed
```

---

## Orphan Detection

At session start, PM checks for items where:
- `work-list.json` has `status: in_progress`
- `logs/<item-id>.md` has a BEFORE record but no AFTER or ERROR record

These are orphaned tasks. PM writes an ERROR record and reports to Owner before proceeding.

---

## Rules

- PM creates `logs/<item-id>.md` when the work item is first dispatched
- One log file per work item — all records appended chronologically
- Log files are local and gitignored (`.claude/logs/` in `.gitignore`)
- PM never deletes log files during the project — they are the audit trail
