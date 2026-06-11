# Maintain Mode — Framework Workflows

Read this when the Owner selects **Maintain** in Framework Mode.

---

## What Maintain Mode Is For

Maintain mode is for improving acc-governance itself — not for running projects. Work done here flows back into the framework template and benefits all future projects.

Ask the Owner:
> "What would you like to do?"
> a. Run the governance-improvement pipeline (structured 5-phase improvement)
> b. Quick fix — modify an agent, template, or doc directly
> c. View framework status (version, open improvement items)

**Stop. Wait for Owner choice.**

---

## Option A — Governance-Improvement Pipeline

For significant changes (new phase, new protocol, policy change, multiple agents affected).

The pipeline lives at `.claude/governance-improvement/` and has 5 phases:

| Phase | Agent | Output |
|-------|-------|--------|
| 01-framework-define | framework-definer | flaw-analysis.md, philosophy.md, improvement-roadmap.md |
| 02-framework-spec | framework-architect | improvement-specs.md, schema-changes.md, agent-changes.md |
| 03-framework-build | framework-builder | updated agents, templates, schemas, docs |
| 04-framework-validation | framework-validator | validation-report.md, regression-report.md |
| 05-framework-ship | framework-shipper | migration-guide.md, adoption-guide.md, changelog.md |

**Running the pipeline:**
1. File an ADR in `decisions/` documenting the proposed change and rationale
2. Start at Phase 1 — brief framework-definer with the problem statement
3. Follow the same 8-step loop as project work (each phase = one loop iteration)
4. At Phase 5 completion, Owner approves merge to main framework
5. Increment `framework.json` version number

**Reviewers for framework phases:** framework-consistency-reviewer, backward-compatibility-reviewer, adoption-readiness-reviewer (plus security-reviewer on every phase).

---

## Option B — Quick Fix

For small, isolated changes (fix a typo in a template, update an agent prompt, add a guardrail).

**Process:**
1. Identify exactly what file(s) need to change
2. Read the file(s) first
3. Present the proposed change to Owner: "I will change [X] to [Y]. Reason: [Z]. Confirm?"
4. **Stop. Wait for Owner approval.**
5. On approval: make the change, run security-reviewer
6. Log the change in `PROGRESS.md` with rationale
7. If the change affects other agents or docs, check for consistency before closing

**No ADR required for quick fixes.** ADR is required if the change affects more than one file or introduces a new protocol.

---

## Option C — View Framework Status

Report:
- Current framework version (from `framework.json`)
- Open improvement items (scan `decisions/` for unresolved ADRs)
- Projects using this framework (scan `projects/*/project.json` for embedded; note standalone projects are self-reported)
- Any agents with no test coverage (scan `.claude/agents/README.md`)

Present the report. Stop. Wait for Owner instruction.

---

## When You Need a New Framework Agent

A new framework agent requires passing a MECE check before anything is written. See `decisions/adr-006-mece-agent-design.md` for the full principle.

**Step 1 — ME check (Mutually Exclusive).**
Name the concern precisely: "This agent reviews ___."
Scan the Reviewer Matrix in `.claude/agents/README.md`. Does any existing agent already cover this concern, even partially?
- **Yes** → stop. Adjust the PM brief to use the existing agent. No new agent needed.
- **No** → proceed.

**Step 2 — Determine scope.**
Is this gap universal — would every project using acc-governance hit it?
- **Yes** → framework agent. Continue to Step 3.
- **No** → project-specific agent. See use-mode.md "When You Need a New Project Agent".

**Step 3 — CE check (Collectively Exhaustive).**
Has this concern caused a missed issue in a real work item? Document the evidence (which project, which work item, what slipped through).
- **No evidence** → defer. Add to `decisions/` as a proposed gap with `Status: Proposed`. Revisit when evidence exists.
- **Evidence exists** → proceed.

**Step 4 — Run the governance-improvement pipeline.**
A new framework agent is a structural change. It requires:
1. ADR in `decisions/` — what concern, why no existing agent covers it, evidence of the gap
2. Start at Phase 1 (`framework-definer`) with the problem statement
3. Reviewers: framework-consistency, backward-compatibility, adoption-readiness, security
4. Increment `framework.json` version on merge

---

## Adding or Modifying an Agent (Mechanics)

Once the "When You Need a New Agent" check passes:

1. Read existing agent definition (if modifying) or find a similar agent as reference
2. Draft the new/modified agent in `.claude/agents/[name].md`
3. Test against a real work-list item before committing
4. Update `.claude/agents/README.md` Reviewer Matrix — verify ME still holds after the addition
5. Run security-reviewer on the agent definition
6. Log in `PROGRESS.md`

**Rules for all agents:**
- Stateless: no memory, all context from files passed in the brief
- Preserve output format: JSON or structured markdown (check output-format.md)
- Never skip security-reviewer

---

## Development Guidelines

**Modifying agents:** Preserve output format → stay stateless → update README.md matrix → test with real work item

**Modifying phases:** Edit phase CLAUDE.md (criteria, deliverables, reviewers) → update templates → document why in ADR → test

**Adding docs:** Keep concise, link to related docs, include examples, sync with actual state files

**Security:** Every commit requires security-reviewer to pass. Use git-author agent only.

**Decision tracking:** Record non-obvious choices as ADRs in `decisions/adr-template.md`

**Framework version:** Increment `framework.json` version after any structural change (new agent, modified protocol, schema change). Patch fixes do not require a version bump.
