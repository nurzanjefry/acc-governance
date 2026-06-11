# Use Mode — Project Workflows

Read this when the Owner selects **Use** in Framework Mode, or when in Project Mode (Mode 2 or 3).

---

## Creating a New Project

**Step 1 — Ask placement:**
> "Where should this project live?"
> a. **Embedded** — I'll create it at `projects/[name]/` inside this framework repo
> b. **Standalone** — provide an external path

**Step 2 — Ask project details:**
- Project name
- Domain (e.g. Finance, Healthcare, E-commerce)
- Problem statement (one sentence)

**Step 3 — Present initialization plan** showing exactly what will be created and where. Stop. Wait for Owner approval.

**Step 4 — On approval, create:**
- `project.json` — identity and framework link
- `project-context.md` — fill from project details (use `01-define/project-context-template.md`)
- `PROGRESS.md` — blank audit log
- `work-list.json` — blank backlog
- `GLOSSARY.md` — seeded with domain terms
- Phase folders `01-define/` through `05-test-ship/` with CLAUDE.md + templates
- `CLAUDE.md` — minimal Mode 2 or 3 startup hook (no `framework.json` — this is a project)

**Step 5 — Confirm link.** Stop. Wait for Owner to say ready before starting Phase 1.

---

## Linking an Existing External Project

**Step 1 — Get project path** from Owner (if in Framework Mode, `framework_source` = current session root — do not ask).

**Step 2 — Validate framework:**
- Read `[framework_source]/framework.json` → confirm valid framework
- Read `[framework_source]/CLAUDE.md` → load protocols

**Step 3 — Check `project.json`:**
- **Exists:** Read it. Identify only missing fields (`framework_source`, `framework_version`). Present delta to Owner: "I will add: [...]. Confirm?" Stop. Wait.
- **Does not exist:** Scan project structure (files, folders, tech stack). Draft `project.json`. Present to Owner. Stop. Wait.

**Step 4 — Check `project-context.md`:**
- **Exists:** Read it. Ask Owner if it needs updating from the scan.
- **Does not exist:** Draft from scan results. Present to Owner. Stop. Wait.

**Step 5 — On Owner approval:** Write `project.json` (merge or create), write `project-context.md`, create minimal project `CLAUDE.md` with Mode 3 startup hook.

**Step 6 — Confirm link.** Stop. Wait for Owner to confirm before starting any project work.

---

## The 8-Step Orchestration Loop

Each work item follows the PM orchestration loop — Orient → Pick → Brief → Review → Revise → Score → Gate → Close out.

See `.claude/docs/orchestration-protocol.md` for the full protocol: step-by-step PM actions, reviewer dispatch, revision cycles, DECISION record requirement, and close-out checklist.

**Owner's role at Step 7:** Approve or reject based on business value, risk, and timeline. PM presents a synthesized summary — not raw reviewer output. Every decision is recorded as a DECISION record in `logs/<item-id>.md`.

---

## Running a Work Item (Practical Steps)

1. Read `work-list.json` — pick the next `status: pending` item
2. Read the phase CLAUDE.md for that item's phase (exit criteria + reviewer list)
3. Read `project-context.md` — brief the producer agent with this context
4. Spawn producer agent → wait for output
5. Spawn all phase reviewers in parallel → collect findings
6. If findings > 0: brief agent to revise, re-run affected reviewers
7. Present scored summary to Owner at Step 7
8. On approval: update `work-list.json` status, append to `PROGRESS.md`

---

## When You Need a New Project Agent

Before creating a project agent, run a MECE check. See `decisions/adr-006-mece-agent-design.md` for the full principle.

**Step 1 — ME check.**
Name the concern precisely: "This agent reviews ___."
Scan the framework Reviewer Matrix (`.claude/agents/README.md`). Does any of the 30 framework agents already cover this?
- **Yes** → stop. Adjust the PM brief. No new agent needed.
- **No** → proceed.

**Step 2 — Is this project-specific or universal?**
Would every project using acc-governance hit this gap, or just this project?
- **Universal** → don't create a project agent. Request a framework agent via maintain-mode.md.
- **Project-specific** → proceed.

**Step 3 — CE check.**
Has this gap caused a missed issue on this project? Name the work item where it slipped through.
- **No evidence yet** → defer. Don't add an agent speculatively.
- **Evidence exists** → proceed to create.

**Step 4 — Create the project agent.**
- File: project's local `.claude/agents/[project-slug]-[role].md`
- Name: `[project-slug]-[role]` — never reuse a framework agent name
- Scope: reads framework docs + project files; writes only within project folder
- Add to the phase CLAUDE.md reviewer list for the phases it applies to
- Verify ME still holds: the new agent must not overlap with any framework agent or other project agent

---

## Customizing for Your Project

- **Add domain terms:** Update `GLOSSARY.md` — all agents check this first
- **Add domain-specific reviewer:** Follow "When You Need a New Project Agent" above before creating anything
- **Adjust exit criteria:** Edit the phase CLAUDE.md for that phase
- **Defer a phase:** Mark work item `status: deferred` in `work-list.json`, log reason in `PROGRESS.md`
