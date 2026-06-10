# Agent Rules — Working Discipline

These rules apply to **all agents** and define how the TallyBite project is organized and executed.

---

## Core Rules

**Read the target folder's CLAUDE.md before editing.**
Each phase folder (`01-define/`, `02-spec/`, etc.) has its own CLAUDE.md. Read it first to understand scope, exit criteria, and what files you're responsible for.

**Keep GLOSSARY.md authoritative.**
All domain terms (Order, Receipt, Extra, etc.) are defined in root `GLOSSARY.md`. Use these exact names everywhere. If you introduce a new term, add it to the glossary first, then use it.

**Record architectural decisions as ADRs.**
Any architectural choice or scope-affecting decision gets an ADR (Architecture Decision Record) in `decisions/`. Examples: "why PostgreSQL instead of MongoDB", "why REST instead of GraphQL". ADRs are immutable history; don't delete or rename them.

**Return a JSON summary when done.**
At the end of every task, return a JSON summary for the PM. See `.claude/agents/output-format.md` for the schema. This tells the PM exactly what was written, what files changed, and whether you're ready for review. No guesswork; no redundant edits.

**Log to PROGRESS.md (or let PM log it).**
At the end of your task, append an entry to `PROGRESS.md` stating: what was done, where you stopped, exit criteria met, and next steps. If you set `updates.progress_md_logged: false` in your JSON summary, PM will log it for you.

**Artifact Cleanup: Creator/Owner Model.**
Temporary artifacts (debug logs, test outputs, session logs, scratch files) are your responsibility to clean up. If you cannot delete them (e.g., agent crashed, external service log, permission issue), declare them in your JSON summary's `artifacts_created` array (set `cleanup_status: "pending_cleanup"`) so PM can clean them up. See `.claude/agents/output-format.md` for schema. PM also runs a safety-net cleanup at session start to remove orphaned artifacts >2 hours old. **Golden rule:** Delete what you create; if you can't, declare it.

---

## By Category

- **[Guardrails](guardrails.md)** — what you must never do without approval (5 specific docs: secrets, scope, git, PII, external services)
- **[Orchestration Protocol](orchestration-protocol.md)** — how the PM runs the producer→review→fix loop (8-step detailed protocol)
  - **[Session Wrap-Up Checklist](session-wrap-up.md)** — Step 8 tactical checklist: log → update → commit → push (every session)

---

## Allowed vs. Forbidden

### Always Allowed ✓
- Read any file in the repo
- Create & edit docs/code within your phase folder
- Add new terms to `GLOSSARY.md`
- Add new ADRs to `decisions/`
- Append to `PROGRESS.md`
- Update your own items in `work-list.json` (status, evidence)

### Requires Approval ✗
- Delete, move, or rename files
- Overwrite existing non-empty docs
- Edit outside your phase folder (except shared files)
- Any git commit, push, or branch operation
- Remove/rename GLOSSARY terms or ADRs
- Destructive shell commands (`rm`, `git reset --hard`, etc.)
- Install dependencies or modify `.claude/` agent defs
- Send content to external services

**See [guardrails.md](guardrails.md) for details on each.**

---

## File Ownership

| Folder | Owner | Reads | Writes |
|---|---|---|---|
| `01-define/` | define-author | All | Only 01-define/ |
| `02-spec/` | spec-author | All | Only 02-spec/ |
| `03-build/` | build-author | All | Only 03-build/ + source tree |
| `04-reconciliation/` | reconciliation-author | All | Only 04-reconciliation/ |
| `05-test-ship/` | ship-author | All | Only 05-test-ship/ |
| `decisions/` | All (read) | All | Only when creating new ADR |
| `GLOSSARY.md` | All (read) | All | Only adding new terms |
| `PROGRESS.md` | All (read) | All | Appending your entry |
| `work-list.json` | All (read) | All | Updating your own items |
| `.claude/`, root `CLAUDE.md`, `README.md` | PM only | All | Only with approval |

---

---

## Artifact Lifecycle & Cleanup Ownership

Artifacts = temporary files created during work (debug logs, session logs, test outputs, scratch files).

### Agent Ownership (Primary)

**When you create a temp file:**
1. Add to `.gitignore` immediately (never commit temp files)
2. Work with it (debug, test, scratch)
3. At task completion:
   - **Success path:** DELETE the file before returning JSON
   - **Failure path:** Leave it and DECLARE it in JSON `artifacts_created` array

**JSON declaration (if you can't delete):**
```json
"artifacts_created": [
  {
    "path": ".claude/logs/agent-phase-a-20260609-143045.md",
    "reason": "Session checkpoint log (agent timed out at Part A2)",
    "cleanup_status": "pending_cleanup"
  }
]
```

### PM Ownership (Fallback)

**If agent declares artifacts:**
1. PM reads `artifacts_created` array from JSON
2. For each artifact with `cleanup_status: "pending_cleanup"`:
   - Delete from disk: `rm <path>`
   - Verify deletion: `ls <path>` should fail
3. Log cleanup in PROGRESS.md: "Cleaned up 2 declared artifacts"
4. Commit cleanup: separate commit with message "cleanup: remove [count] agent artifacts"

**If agent crashes (no JSON returned):**
1. PM detects at Step 1a: orphaned artifacts >2 hours old
2. PM cleans up: `find .claude/logs -name "agent-*.md" -mtime +2h -delete`
3. Log in PROGRESS.md: "Session startup: cleaned up N orphaned artifacts"

### Guardrails (Runaway Prevention)

If an agent creates artifacts faster than expected (thrash scenario):
- Artifact creation rate >20/min → PM stops agent
- Total artifacts >100 per task → PM stops agent and escalates to human
- Total artifact size >1 GB → PM stops agent and escalates

See `.claude/config.json` for configurable limits.

---

## Phase Handoff

When your phase is done:
1. All exit criteria met (from CLAUDE.md in your folder)
2. All files filled, no TODOs
3. **All temp artifacts deleted** (or declared in JSON)
4. Return JSON summary to PM
5. PM runs reviewers (terminology, scope, decisions, security)
6. PM updates tracking (work-list.json, PROGRESS.md)
7. Next phase agent picks up

You don't update `work-list.json` status to `passing`; PM does that after reviewers PASS.
