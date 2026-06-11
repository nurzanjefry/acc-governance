# Guardrails — Require Explicit Human Approval

When in doubt, stop and ask before proceeding. These apply to **every agent and every phase**.

Default: always ask. Exception: if the task explicitly requires a restricted action and you've explained why, the human can pre-authorize it in that session.

---

## By Category

- **[Secrets & credentials](guardrails_secrets.md)** — never commit keys/tokens, rotation policy, pre-commit hook enforced
- **[Scope & files](guardrails_scope.md)** — no deletes, no overwrites, stay within your phase folder
- **[Git & history](guardrails_git.md)** — no force-push, no resets, approval gates before any commit/push
- **[PII & data](guardrails_pii.md)** — data sensitivity, retention rules, access control, masking
- **[External services](guardrails_external.md)** — no data egress, no third-party uploads without approval

---

## The Rule

**Never do these without the human's explicit go-ahead in the current session:**

1. Delete or move any file or directory (especially anything you didn't create)
2. Overwrite or wholesale-replace an existing non-empty doc (editing in place is OK; wiping is not)
3. Edit files outside your phase folder, except:
   - Adding new terms to `GLOSSARY.md` (never removing/renaming existing terms)
4. Remove/rename canonical terms in `GLOSSARY.md` or delete/supersede ADRs (adding new ones is OK)
5. Run destructive shell commands: `Remove-Item`, `git reset --hard`, `git clean -f`, force-push, history rewrite
6. Any git commit, push, or branch operation
7. Install dependencies, modify `.claude/` agent defs, edit root `CLAUDE.md` or `README.md`
8. Send repo content to external services or make network calls beyond what the task explicitly requires
9. Create, edit, or delete any file in `.claude/docs/` — these are PM-owned framework docs. Agents may read them but never write to them.
10. Create files at the repository root — root-level files (`CLAUDE.md`, `framework.json`, `project.json`, `project-context.md`, `GLOSSARY.md`) are PM-owned. Agents write only within their assigned phase folder. Declare everything else in the JSON summary — PM writes it.

---

## Always Allowed

- Read anything
- Create and edit docs/code within your phase folder
- Add new glossary terms and ADRs
- Return JSON summary to PM (the only way to trigger shared file updates)
