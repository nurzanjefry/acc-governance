# Agent Output Format (Required for all agents)

When an agent completes a task, it **MUST** return a JSON summary for the PM. This eliminates guesswork, prevents redundant file edits, and saves ~5-10% of orchestration tokens per task.

## JSON Schema

```json
{
  "task_id": "spec-001",
  "phase": "02-spec",
  "status": "complete",
  "files_written": [
    {
      "path": "02-spec/stack.md",
      "lines": 234,
      "scope": "6 tech choices with rationales and architecture diagram"
    },
    {
      "path": "02-spec/data-model.md",
      "lines": 790,
      "scope": "14 entities: Companies, Users, Orders, Receipts, FinanceRecords, AuditLog, etc."
    }
  ],
  "updates": {
    "glossary_terms_added": 10,
    "adr_created": 0,
    "progress_md_logged": false
  },
  "exit_criteria_met": true,
  "verification_notes": "No TODOs remaining. All entity names match GLOSSARY.md. RBAC + audit logging modeled. Offline sync supported via idempotency_key.",
  "ready_for_review": true,
  "issues": [],
  "artifacts_created": [],
  "references_to_update": []
}
```

## Field Definitions

| Field | Type | Required | Notes |
|---|---|---|---|
| `task_id` | string | ✓ | work-list.json item ID (e.g., "spec-001") |
| `phase` | string | ✓ | phase folder (e.g., "02-spec") |
| `status` | enum | ✓ | "complete" \| "partial" \| "blocked" \| "failed" |
| `files_written` | array | ✓ | List of deliverables. Each: {path, lines, scope}. path = relative to repo root. scope = 1-line summary of what's in the file. |
| `updates.glossary_terms_added` | number | ✓ | Count of new terms added to GLOSSARY.md (0 if none) |
| `updates.adr_created` | number | ✓ | Count of new ADRs created in decisions/ (0 if none) |
| `updates.progress_md_logged` | boolean | ✓ | Did you log the entry to PROGRESS.md? (false = PM will log it) |
| `exit_criteria_met` | boolean | ✓ | Do the deliverables satisfy work-list.json verification criteria? |
| `verification_notes` | string | ✓ | Evidence: 2-3 bullets showing TODOs completed, constraints satisfied, no contradictions |
| `ready_for_review` | boolean | ✓ | Is this ready to dispatch to reviewers, or does it need agent revision first? |
| `issues` | array | optional | Blockers, unknowns, or known gaps. Empty list = [] if none. |
| `artifacts_created` | array | optional | Temporary files created during work (debug logs, test outputs, session logs). Each: {path, reason, cleanup_status}. Empty list = [] if none created or all cleaned up. **cleanup_status** values: "deleted" (agent already deleted it, info only), "pending_cleanup" (agent couldn't delete; PM will delete). PM uses this to clean up after agent finishes. |
| `references_to_update` | array | required | Docs where this task's output should be linked. Each: {file, location, link_text}. Empty list = [] if no references needed. PM executes all reference writes — agents never write these directly. Example: `{"file": "02-spec/CLAUDE.md", "location": "deliverables list", "link_text": "data-model.md"}` |

## Example: spec-001 & spec-002 complete

```json
{
  "task_id": "spec-001_spec-002",
  "phase": "02-spec",
  "status": "complete",
  "files_written": [
    {
      "path": "02-spec/stack.md",
      "lines": 234,
      "scope": "Frontend (React+Vite), Backend (Node+Fastify), Storage (PostgreSQL+MinIO), AI (Claude API), Hosting (Docker). Each choice with rationale. Architecture diagram. Offline sync flow documented."
    },
    {
      "path": "02-spec/data-model.md",
      "lines": 790,
      "scope": "14 entities (Companies, Users, Orders, Receipts, FinanceRecords, AuditLog, etc). RBAC via UserCompanyRoles M:N. Money as integer cents. Soft-delete for Orders. All relationships with FK constraints and cascading rules. Audit logging INSERT-only."
    }
  ],
  "updates": {
    "glossary_terms_added": 10,
    "adr_created": 0,
    "progress_md_logged": true
  },
  "exit_criteria_met": true,
  "verification_notes": "Stack fully documented with rationales; no TODOs. Data model covers all 9 steps: ordering (Cat/Prod/Extra/Order/LineItem), receipt capture (Receipt/ReceiptObject), reconciliation (FinanceRecord). RBAC modeled via M:N. Audit logging via INSERT-only AuditLog table. Offline sync via idempotency_key + upload_status. All 23 original GLOSSARY terms preserved; 10 new terms (Company, User, 5 roles, AuditLog, RBAC, data isolation) added and documented. No conflicts with product-definition.md or roles-and-permissions.md.",
  "ready_for_review": true,
  "issues": [],
  "artifacts_created": []
}
```

## How the PM uses this

1. **Read the JSON** (takes <10 tokens to parse)
2. **Spot-check files** — read 20-30 lines from each file to confirm real content
3. **Verify exit criteria** — check JSON `exit_criteria_met` flag against work-list.json
4. **Dispatch reviewers** — send files to terminology/scope/decisions/security reviewers
5. **Update tracking** — only after reviewers PASS, PM updates work-list.json with evidence and marks item `passing`

## Why this format?

- **Concise:** PM doesn't re-read all files; trusts agent summary
- **Unambiguous:** JSON schema prevents misinterpretation
- **Prevents redundant edits:** PM sees exactly what was written; no guessing
- **Saves tokens:** Parsing JSON < parsing prose; no second-guessing what to update
- **Consistent:** All agents follow the same contract

## What agents should NOT do

- ❌ Manually update `work-list.json` with `passing` status (PM does this after reviewers PASS)
- ❌ Manually append to `PROGRESS.md` (PM does this as part of closeout)
- ❌ Assume PM will update tracking files without clear summary (return JSON so PM knows exactly what to update)
- ❌ Leave temporary/debug files in the repo (logs, test outputs, scratch files). Clean them up before finishing. If you can't delete them, declare in `artifacts_created` array so PM cleans up.

## Status enum details

- **`complete`** — all exit criteria met, no known issues, ready for review
- **`partial`** — some deliverables done, but others incomplete or blocked; PM will route to revision or escalation
- **`blocked`** — cannot proceed; unknown answer or dependency unsolved; issue field explains blocker
- **`failed`** — technical failure (file write failed, agent error); issue field explains failure
