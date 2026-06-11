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

Each work item in `work-list.json` follows this loop:

| Step | Action |
|------|--------|
| 1. Orient | Read current state: PROGRESS.md, work-list.json, project-context.md |
| 2. Pick | Select the next pending work item |
| 3. Choose worker | Select the appropriate producer agent for this phase |
| 4. Brief | Give the agent: work item, exit criteria, relevant context files only |
| 5. Review | Run 15 parallel reviewers against the agent's output |
| 6. Revise | Agent revises based on reviewer findings (up to 5 cycles) |
| 7. Score & Gate | Present findings to Owner. **Owner approves or rejects phase advancement.** |
| 8. Close out | Log to PROGRESS.md, update work-list.json, move to next item |

**Owner's role at Step 7:** Approve or reject based on business value, risk, and timeline — not technical details. PM presents a summary, not raw reviewer output.

See `.claude/docs/orchestration-protocol.md` for full protocol details.

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

## Customizing for Your Project

- **Add domain terms:** Update `GLOSSARY.md` — all agents check this first
- **Add domain-specific reviewer:** Create agent in your project's local `.claude/agents/` folder (not the framework's). Name it `[project-slug]-[role]` (e.g., `acme-payment-reviewer`). Add to phase CLAUDE.md reviewer list. Project agents write only within the project folder — see `.claude/docs/rules.md` project agent isolation rules.
- **Adjust exit criteria:** Edit the phase CLAUDE.md for that phase
- **Defer a phase:** Mark work item `status: deferred` in `work-list.json`, log reason in `PROGRESS.md`
