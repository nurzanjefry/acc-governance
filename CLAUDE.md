# CLAUDE.md — Governance Framework Rules

This file defines rules for the governance framework itself, not for specific projects using it.

---

## What This Framework Is

A deterministic, stateless project management system for guiding teams through 5 phases:
1. **Define** — Product definition
2. **Spec** — Technical architecture
3. **Build** — Implementation
4. **Reconciliation** — Domain logic validation
5. **Test & Ship** — Testing & deployment

Each phase has exit criteria, specialist reviewers, and hard gates. No phase advances until reviewers PASS.

---

## Core Principles

1. **State-in-files** — All project state lives in git (work-list.json, PROGRESS.md, ADRs), never in memory
2. **Agents are stateless** — Any agent can pick up work mid-session and resume from files
3. **Parallel review** — All reviewers run at once, not sequentially
4. **Hard gates** — No blocker = no ship; human judgment required at phase completion
5. **Deterministic** — Same 8-step PM loop every time (reproducible, auditable)

---

## The 8-Step PM Loop

Every task follows this loop (documented in `.claude/docs/orchestration-protocol.md`):

1. Orient (understand the task)
2. Pick (choose work-list item)
3. Choose worker (select producer agent)
4. Brief & dispatch (send to agent with exit criteria)
5. Review (run all reviewers in parallel)
6. Revise (producer fixes findings, max 5 cycles)
7. Score & gate (rubric: 6 dimensions, 0–2 each, max 12)
8. Close out (mark passing, log to PROGRESS.md)

---

## Customization (How to Adapt for Your Project)

### Add Phases
If your project needs more than 5 phases:
1. Create `0X-name/CLAUDE.md` with exit criteria and reviewers
2. Update `.claude/docs/orchestration-protocol.md` to include new phase
3. Create a producer agent for the new phase

### Add Reviewers
If you need a domain-specific reviewer (e.g., compliance-reviewer, ML-reviewer):
1. Create `.claude/agents/compliance-reviewer.md` following the pattern
2. Update `.claude/agents/README.md` to add it to the matrix for relevant phases
3. Update phase CLAUDE.md files to include in the reviewer list

### Change Exit Criteria
Each phase CLAUDE.md lists default exit criteria. Override for your project:
1. Edit the phase CLAUDE.md file
2. Document why the change is needed (comment or ADR)

### Adjust Reviewer Count
If you need fewer reviewers (for MVP/low-stakes), disable them:
1. Don't remove agent definitions (they're shared)
2. Update phase CLAUDE.md to exclude them from the reviewer matrix
3. Log the rationale in PROGRESS.md

---

## Rules (Hard Constraints)

**NEVER without explicit human approval:**
- Delete files or ADRs
- Remove glossary terms
- Move files between phases (except during extraction)
- Run destructive shell commands
- Make commits or push without security review
- Skip security-reviewer (runs every phase)

**ALWAYS:**
- Update GLOSSARY.md before using new terminology
- Create ADRs for non-obvious decisions
- Log to PROGRESS.md after every review cycle
- Mark work-list.json items with verification evidence

---

## For New Projects

1. Copy acc-governance/ to projects/my-project/
2. Update GLOSSARY.md with your domain terms
3. Read the phase CLAUDE.md for where you are (e.g., 01-define/CLAUDE.md)
4. Follow the 8-step PM loop via the agents
5. Update work-list.json and PROGRESS.md as you go

**State lives in files.** If a session dies, the next one resumes from PROGRESS.md + work-list.json.

---

## References

- `.claude/docs/orchestration-protocol.md` — Full PM loop walkthrough
- `.claude/docs/rules.md` — Core framework rules
- `.claude/docs/guardrails.md` — Restricted actions
- `.claude/agents/README.md` — Agent registry and evaluation matrix
- `.claude/docs/FRAMEWORK-EVOLUTION.md` — How to evolve the framework itself
