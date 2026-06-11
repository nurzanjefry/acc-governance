# Agent Rules — Working Discipline

These rules apply to **all agents** and define how the acc-governance framework and all projects governed by it are organized and executed.

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

**Never write to PROGRESS.md directly — PM owns it.**
Always set `updates.progress_md_logged: false` in your JSON summary. PM writes the PROGRESS.md entry after receiving your JSON. This prevents concurrent write conflicts when multiple agents run in parallel.

**Doc discipline: 150-line limit.**
No doc should exceed 150 lines without PM approval. If a doc grows beyond 150 lines, split it into focused sub-docs and link from the parent. Purpose: prevents context bloat for agents reading the file.

**Context discipline: read only what your brief requires.**
Do not pre-emptively load `use-mode.md`, `maintain-mode.md`, `framework-overview.md`, or any doc not explicitly named in your task brief. Load only the files your task requires. Purpose: keeps agent context focused.

**No duplicate docs.**
Before creating a new doc, verify the content doesn't belong in an existing one. New docs require PM approval. If in doubt, append to an existing doc instead. Purpose: prevents fragmentation and orphaned files.

**Agent concurrency model: PM is the sole writer to shared files.**
When PM dispatches multiple agents in parallel, agents write only to their assigned phase folder output files. Agents never write to shared files directly — they return JSON findings to PM. PM collects all agent JSONs first, then writes to shared files in a single sequential pass. Shared files: `PROGRESS.md`, `work-list.json`, `GLOSSARY.md`, `project-context.md`, and any reference or index file.

**Reference updates belong to PM, not agents.**
When you create an artifact, declare it in your JSON summary with a `references_to_update` list — the parent doc and location where this artifact should be linked. Do not write the reference yourself. PM executes all reference updates after collecting all agent JSONs for the work item. See `.claude/agents/output-format.md` for the `references_to_update` schema.

**Agent lifecycle: every task has a BEFORE and AFTER record.**
PM writes a BEFORE record to `logs/<item-id>.md` before dispatching you. You write your output to your phase folder. You return JSON to PM. PM writes the AFTER record. These two records are the recovery point if you error mid-task. You do not write to `logs/` — PM owns that file. See `.claude/docs/log-format.md` for the record structure.

**Orphan detection: PM checks for abandoned tasks at session start.**
PM scans `work-list.json` for items with `status: in_progress` that have a BEFORE record but no AFTER record in `logs/<item-id>.md`. These are orphaned tasks. PM reports them to Owner before doing any other work in the session.

**Project agents: naming, priority, and isolation.**
Projects may define their own agents alongside the 30 framework agents. Three rules:

1. **Priority:** Framework agents always win. If a project agent has the same name as a framework agent, the framework agent is used. A naming collision is a project misconfiguration — fix it by renaming the project agent.
2. **Naming:** Project agents must be prefixed with the project slug: `[project-slug]-[role]`. Examples: `acme-payment-reviewer`, `fintech-fraud-checker`. Never reuse a framework agent name.
3. **Isolation:** Project agents write only within their project folder. They may read framework docs and the project's state files. They may not write to the framework's `.claude/` directory, other project folders, or shared framework state files outside their project root.

Violation of any isolation rule → PM stops the agent immediately and reports to Owner.

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
- Return JSON summary to PM (including `references_to_update`)

### Requires Approval ✗
- Delete, move, or rename files
- Overwrite existing non-empty docs
- Edit outside your phase folder
- Write directly to any shared file (`PROGRESS.md`, `work-list.json`, `GLOSSARY.md`, `project-context.md`)
- Write reference/index updates to any doc — declare in JSON, PM executes
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
| `GLOSSARY.md` | PM only | All | Never — declare new terms in JSON, PM writes |
| `PROGRESS.md` | PM only | All | Never — PM writes after collecting agent JSON |
| `work-list.json` | PM only | All | Never — PM updates status after gate decisions |
| `.claude/docs/` | PM only | All | Never — read-only for agents |
| `.claude/agents/` | PM only | All | Only with Owner approval |
| `framework.json` | PM only | All | Never — framework repo identity |
| `project.json` | PM (creates at init) | All | Never — PM merges on Owner approval |
| `project-context.md` | PM (creates/updates) | All | Never — PM updates at phase transitions |
| Root `CLAUDE.md`, `README.md` | PM only | All | Only with Owner approval |

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
