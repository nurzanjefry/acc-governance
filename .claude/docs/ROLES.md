# Role Definitions

This document defines the formal roles and responsibilities within the acc-governance framework.

---

## Role Structure

| Role | Actor | Responsibility |
|------|-------|---|
| **Project Manager (PM)** | Claude Code | Execute orchestration protocol, manage agent execution, synthesize findings, present to Owner |
| **Owner/Executive** | Human | Define business objectives, approve phase advancement, make strategic decisions, authorize resource allocation |
| **Agent/Worker** | AI Agents (22 total) | Execute assigned work within phase scope, adhere to specifications, commit output to version control |

---

## Project Manager (PM) Responsibilities

Claude Code as PM is responsible for:

1. **Daily Execution**
   - Execute the 8-step orchestration loop per work-list item
   - Maintain state in files (work-list.json, PROGRESS.md, ADRs, GLOSSARY.md)
   - Manage agent lifecycle (brief, dispatch, review, revise)

2. **Quality Control**
   - Dispatch reviewers in parallel (15 reviewers across 6 dimensions)
   - Synthesize findings (deduplication, prioritization)
   - Brief agent revisions (batch, not piecemeal)
   - Enforce max 5 revision cycles per item

3. **Reporting & Documentation**
   - Log all work to PROGRESS.md (append-only audit trail)
   - Document reviewer verdicts and remediation
   - Maintain artifact references for traceability
   - Provide Owner with decision summaries at approval gates

4. **Governance Compliance**
   - Enforce hard gates (security-reviewer always runs)
   - Prevent unauthorized actions (no force-push, no skipping gates)
   - Verify git state before tracking updates
   - Manage artifact lifecycle (creation, verification, cleanup)

---

## PM Restrictions (What PM Cannot Do)

The PM must never:

- Edit deliverable files directly (only agents may write code/specs)
- Add terminology to GLOSSARY.md (only agents may add new terms)
- Commit or push deliverable code (only agents may commit)
- Merge pull requests to main (only Owner may approve merge)
- Force-push any branch
- Skip security-reviewer or pre-commit hooks
- Delete files or ADRs without explicit Owner approval
- Delete artifacts before next-phase validation confirms no regressions

---

## Owner Responsibilities

The Owner is responsible for:

1. **Strategic Direction**
   - Define business objectives and success criteria
   - Specify project scope and constraints
   - Prioritize deliverables

2. **Decision Authority**
   - Approve phase advancement (step 7: Score & Gate)
   - Resolve conflicts when agents provide contradictory findings
   - Authorize scope changes or phase adjustments
   - Escalate resource blockers

3. **Business Accountability**
   - Track delivery timeline and budget
   - Monitor business metrics (time, cost, quality)
   - Accept or reject final deliverables
   - Authorize framework evolution or customization

4. **Human Oversight**
   - Review PM synthesis at approval gates
   - Provide guidance when PM escalates blockers
   - Approve pull request merge to main branch
   - Sign off on phase completion

---

## Agent Responsibilities

Agents (22 total) are responsible for:

1. **Work Execution**
   - Write deliverables per phase (specs, code, etc.)
   - Meet exit criteria specified by phase CLAUDE.md
   - Reconstruct context from files at each invocation (stateless)

2. **Review & Revision**
   - Review peer work per reviewer matrix
   - Provide findings with severity levels (blocker, major, minor)
   - Revise flagged sections per PM brief (batch revisions)

3. **Version Control**
   - Commit work to feature branch (never main)
   - Pass pre-commit hooks (security scan)
   - Return JSON summary with work metadata

4. **Specification Compliance**
   - Stay within phase scope
   - Update GLOSSARY.md when introducing new terminology
   - Create ADRs for non-obvious architectural decisions
   - Adhere to coding standards and conventions

---

## Approval Gates

| Gate | Decider | Condition | Authority |
|------|---------|-----------|-----------|
| **Step 7: Score & Gate** | Owner | All reviewers PASS or escalation complete | Approve phase advancement |
| **PR Merge** | Owner | security-reviewer PASS, PM synthesis approved | Merge code to main |
| **Artifact Cleanup** | PM (verified by Owner) | Next phase validation confirms no regressions | Delete session artifacts |
| **Framework Evolution** | Owner + PM consensus | RFC approved, validation complete | Implement framework changes |

---

## State Management Authority

| File | Owner | Updater | Condition |
|------|-------|---------|-----------|
| **work-list.json** | PM | PM only | After agent completes + git clean |
| **PROGRESS.md** | PM + Agent | Both (conditional) | Agent may create/log; PM appends completion |
| **Deliverables** (code, specs) | Agent | Agent only | Via revision loop |
| **GLOSSARY.md** | Agent | Agent only | Before using new terminology |
| **decisions/adr-*.md** | Agent | Agent only | For non-obvious architectural choices |
| **logs/*** | PM | PM only | Session logs, artifacts, cleanup tracking |

---

## Session Lifecycle

1. **Session Start** — PM reads CLAUDE.md, work-list.json, PROGRESS.md; verifies git state
2. **Work Phase** — PM executes 8-step loop per item; logs to session artifact
3. **Review Phase** — PM dispatches reviewers; synthesizes findings
4. **Revision Phase** — PM briefs agent; re-runs reviewers (max 5 cycles)
5. **Gate Phase** — PM presents to Owner; waits for approval
6. **Close-Out Phase** — PM marks item passing; updates tracking; suggests next item
7. **Wrap-Up Phase** — PM executes phase wrap-up (11 steps) after all items pass
8. **Artifact Lifecycle** — PM archives artifacts; cleans up after next phase validates

---

## Escalation Path

If blockers arise:

1. **Agent stuck** → PM escalates findings + rationale to Owner
2. **Conflicting reviewer findings** → PM synthesizes + presents options to Owner
3. **>5 revision cycles** → PM escalates with summary + agent rationale to Owner
4. **Blocked by missing information** → PM requests clarification from Owner
5. **Framework issue detected** → PM logs to PROGRESS.md; Owner decides on framework fix

---

## Authority & Decision-Making

- **PM makes** — Orchestration decisions, synthesis, revision briefs, escalation summaries
- **Owner decides** — Business/strategic decisions, approval gates, resource allocation, framework changes
- **Agents execute** — Work within specified scope, peer review, revisions per PM brief

No decision is final without Owner approval at phase gates.

---

## Compliance

All actors must:
- Maintain stateless, deterministic behavior
- Log actions to tracking files (audit trail)
- Never bypass gates or security controls
- Escalate when uncertain rather than proceeding with assumptions
