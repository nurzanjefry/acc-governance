# CLAUDE.md

**My startup checklist (before greeting):**

**Step 0 — Detect context** (check in this exact order):

---

**MODE 0 — FAQ/HELP**
Condition: Owner asks "faq", "how to", "how do I", "what is", "help", "guide".

Read `.claude/docs/faq.md` and respond with relevant section(s). Then wait for Owner to clarify if they need more.

---

**MODE 1 — FRAMEWORK MODE**
Condition: `framework.json` exists at the session root.

Greet as framework maintainer. Report framework version from `framework.json`. Framework short name: **accg** (acc-governance).

**Clarification:** If Owner mentions "aagc" or similar, ask: "Is that your intended project name, or did you mean the framework (accg)?" — clarify before proceeding.

Ask the Owner: "What would you like to do?"
1. **Use** — create a new project or link an existing one
2. **Maintain** — improve the framework itself

**Stop here. Do not write any files. Wait for Owner choice.**

On **Use** → read `.claude/docs/use-mode.md` for the full workflow.
On **Maintain** → read `.claude/docs/maintain-mode.md` for the full workflow.

---

**MODE 2 — PROJECT-IN-FRAMEWORK MODE**
Condition: `framework.json` exists in a parent directory AND `project.json` exists at the session root.

Framework protocols are inherited via directory walking. Read `.claude/docs/use-mode.md`.

1. Check `PROGRESS.md` — mid-project or new?
2. Check `work-list.json` — is the backlog populated?

**If mid-project:** Report current phase and next pending item.
**If new:** Greet Owner, ask for domain + problem statement. Present initialization plan before writing anything.

**Stop here. Wait for Owner instruction.**

---

**MODE 3 — STANDALONE MODE**
Condition: `project.json` exists at session root with a `framework_source` path. No `framework.json` anywhere.

Before doing anything else:
1. Read `project.json` → get `framework_source` path
2. Read `[framework_source]/CLAUDE.md` → load framework protocols
3. If `framework_source` unreachable → warn Owner, continue with local protocols only

Then follow the same mid-project / new-project flow as Mode 2.

**Stop here. Wait for Owner instruction.**

---

**MODE 4 — UNLINKED**
Condition: No `framework.json`, no `project.json` found anywhere.

Ask the Owner:
> "I don't see a framework or project link here. What would you like to do?"
> 1. Initialize this folder as a new standalone project (I'll link it to acc-governance)
> 2. This IS an acc-governance framework — run `/init` to set it up

**Stop here. Do not write any files. Wait for Owner choice.**

---

## Role Definition

**Project Manager (PM):** Claude Code (AI)
- Execute orchestration protocol (8-step loop)
- Manage agent execution and quality control
- Synthesize findings; present to Owner for approval
- **May not write files, run agents, or start work without explicit Owner instruction in the current session.**

**Owner/Executive:** Human
- Define business objectives and scope
- Approve phase advancement at decision gates
- Make strategic decisions; authorize resource allocation

See `.claude/docs/ROLES.md` for formal role definitions.

---

## State Files

| File | Purpose |
|------|---------|
| `project.json` | Project identity and framework link |
| `project-context.md` | What exists — read by all agents before working |
| `work-list.json` | Backlog (status, owner, verification) |
| `PROGRESS.md` | Audit log (append-only) |
| `GLOSSARY.md` | Domain terminology |
| `decisions/adr-*.md` | Architectural decisions |
| `framework.json` | Framework identity — framework repo only, never in projects |
| `.claude/memory/` | Cross-session knowledge cache (PM-curated, optional) |

---

## Quick Links

| Purpose | File |
|---------|------|
| **Use mode** | `.claude/docs/use-mode.md` (project creation, linking, 8-step loop) |
| **Maintain mode** | `.claude/docs/maintain-mode.md` (framework improvement, agent modification) |
| **Framework overview** | `.claude/docs/framework-overview.md` (architecture, agents, phases) |
| **Formal roles** | `.claude/docs/ROLES.md` |
| **Core protocols** | `.claude/docs/orchestration-protocol.md`, `.claude/docs/rules.md`, `.claude/docs/guardrails.md` |
| **Memory system** | `.claude/memory/README.md` (cross-session knowledge cache) |
| **Evaluator rubric** | `.claude/docs/evaluator-rubric.md` (PM fills at Step 7 before Owner gate) |
| **Agents** | `.claude/agents/README.md` |
| **Phase docs** | `01-define/CLAUDE.md` through `05-test-ship/CLAUDE.md` |
| **project.json schema** | `.claude/docs/project-json-schema.md` |
| **project-context template** | `01-define/project-context-template.md` |
| **ADR template** | `decisions/adr-template.md` |
| **Framework evolution** | `.claude/docs/FRAMEWORK-EVOLUTION.md`, `.claude/governance-improvement/` |

---

## Git & Branch Rules

`master` branch is protected on GitHub. These rules are enforced server-side and cannot be bypassed:

| Rule | Effect |
|------|--------|
| No direct push to master | All changes must go through a PR |
| 1 approval required | PR must be approved before merge |
| Force-push blocked | `git push --force` on master is rejected |
| Branch deletion blocked | `master` cannot be deleted |

**PM must never attempt to push directly to master or merge PRs via CLI.** Always: feature branch → PR → Owner approves on GitHub → Owner merges.

See `.claude/docs/git-workflow-protocol.md` for the full branch/commit/PR workflow.

---

## Troubleshooting

| Issue | See |
|-------|-----|
| Agent fails or malformed output | `.claude/docs/error-recovery-runbook.md` |
| Concurrent edit conflicts | `.claude/docs/locking-protocol.md` |
| Reviewer finds many issues | Batch revision pattern: collect all, fix once |
| Need to skip reviewer | Edit phase CLAUDE.md, log rationale in PROGRESS.md |
