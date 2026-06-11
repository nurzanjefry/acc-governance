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

## DECISION Record (PM writes after Owner responds at Step 7)

```markdown
## DECISION — <item-id>

- Time: <ISO 8601>
- Decision: Accept | Request changes | Reject
- Owner rationale: <verbatim or close paraphrase — required, not optional>
- Outcome:
  - Accept → item status set to `passing`, proceed to step 8
  - Request changes → revision loop restarted with Owner feedback outranking reviewers
  - Reject → item status set to `reopened`, reason: <Owner's reason>
- Owner: <name or "Framework Owner">
```

**When to write:** Immediately after Owner responds at the Step 7 approval gate. Every gate decision is recorded — accept, change request, and reject alike.

**Why:** Owner decisions are the governance mechanism. If a decision is not captured, there is no audit trail for why the project moved in a particular direction. This record is the institutional memory for judgment calls that no reviewer can derive from code.

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
