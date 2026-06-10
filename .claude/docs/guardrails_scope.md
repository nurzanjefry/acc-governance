# Guardrails: Scope & Files

## Stay within your phase folder

Each agent owns its phase folder. Don't edit files outside your phase without explicit approval.

**Your phase folder:** Read CLAUDE.md in `.claude/agents/` to see which phase you own.
- `define-author` → `01-define/` only
- `spec-author` → `02-spec/` only
- `build-author` → `03-build/` only
- `reconciliation-author` → `04-reconciliation/` only
- `ship-author` → `05-test-ship/` only

**Exceptions (always allowed, no approval needed):**
- Append to `PROGRESS.md` (log your work)
- Add new terms to `GLOSSARY.md` (never remove/rename existing)
- Update your own items in `work-list.json` status/evidence fields

**Other shared files (require approval):**
- Root `CLAUDE.md` — changes to working rules, guardrails, flow description
- Root `README.md` — changes to project overview
- `.claude/` agent definitions — changes to roles, reviewer matrix, orchestration
- Any decision (existing ADRs, new ADRs)

---

## Never delete or move files

Don't:
- `Remove-Item` / `rm -rf` anything (except temp test files you created)
- Rename files without human approval
- Move files between folders
- Clean up "old" versions of files without asking

**Why:** The human might be using those files for something. If you think a file should be deleted, ask first with a clear reason.

**Exception:** Temp files you created during a task (e.g., `.test.ts`, debugging notes) can be cleaned up before you finish.

---

## Never overwrite existing docs

Don't:
- Wholesale-replace an existing non-empty file with `Write` tool
- Erase sections and rewrite them without asking

**OK:** Editing in-place with the `Edit` tool to fix specific sections.

**Not OK:** Reading a file, then using `Write` to replace the entire content.

If a doc needs a major rewrite, ask the human first.

---

## Investigate before deleting

If you find unexpected state (unfamiliar files, branches, directories), investigate before deleting:
- Is it someone's in-progress work?
- Is it needed by another phase?
- Could it be referenced elsewhere?

Example: if you see a file `old-data-model.md` and wonder if it should be deleted, grep for references first (`grep -r "old-data-model" .`). If it's referenced, leave it alone.

---

## Phase boundaries are hard

You can read anything in the repo. But you can only write (create, edit) within your phase folder + the shared files listed above.

If you need to change something outside your phase:
1. Document why in your `PROGRESS.md` entry
2. Ask the human for approval
3. Wait for go-ahead before editing
