# Framework Overview

Reference document. Read when you need to understand acc-governance's architecture, agents, or design principles. Not loaded on every session — agents are briefed with this only when they need it.

---

## What acc-governance Is

A fully-agentic, deterministic framework for end-to-end product creation and orchestration through 5 phases (Define → Spec → Build → Reconciliation → Test & Ship).

**Key design principles:**
- Stateless agents — no memory; all state lives in git files
- 15 parallel reviewers validate every deliverable across 6 quality dimensions
- Deterministic 8-step loop — auditable, resumable from PROGRESS.md
- Human gates at each phase — Owner approves, never autonomous

---

## Five Project Phases

| Phase | Folder | Producer | Deliverables |
|-------|--------|----------|--------------|
| 1. Define | `01-define/` | define-author | PRD, user journey, UI/UX ideas, roles |
| 2. Spec | `02-spec/` | spec-author | Tech spec, stack decision, data model |
| 3. Build | `03-build/` | build-author | Build order, implementation code, migrations |
| 4. Reconciliation | `04-reconciliation/` | reconciliation-author | Domain logic spec, business rules, audit trail |
| 5. Test & Ship | `05-test-ship/` | ship-author | Test plan, tracking plan, deployment runbook |

Each phase has its own `CLAUDE.md` with exit criteria, deliverables, and reviewer list.

---

## 30 Agents

### 5 Project Producers
One per phase. Writes deliverables.

define-author, spec-author, build-author, reconciliation-author, ship-author

### 15 Project Reviewers
Run in parallel after each producer. Validate across 6 dimensions.

| Dimension | Reviewers |
|-----------|-----------|
| Correctness | terminology-reviewer, scope-reviewer, decisions-reviewer |
| Design | architecture-reviewer, data-model-reviewer, security-architect |
| Quality | test-strategy-reviewer, performance-reviewer, observability-architect |
| Operations | api-contract-reviewer, infrastructure-reviewer, monitoring-reviewer, tech-debt-reviewer |
| Documentation | docquality-reviewer |
| Permanent (every phase) | security-reviewer ★ |

### 1 Executor
git-author — commits and opens PRs after security-reviewer passes.

### 1 Initializer
project-init — populates a new project with structure and glossary.

### 5 Framework Producers (Govern the Framework Itself)
framework-definer, framework-architect, framework-builder, framework-validator, framework-shipper

### 3 Framework Reviewers
framework-consistency-reviewer, backward-compatibility-reviewer, adoption-readiness-reviewer

---

## Framework Evolution Pipeline

Lives at `.claude/governance-improvement/`. Used when the framework itself needs improvement.

| Phase | Focus |
|-------|-------|
| 01-framework-define | Analyze flaws, document philosophy |
| 02-framework-spec | Design improvements |
| 03-framework-build | Implement changes |
| 04-framework-validation | Test on real projects |
| 05-framework-ship | Migration guide, adoption guide, changelog |

Same 8-step loop as project work. Owner approves at each phase gate.

---

## Project Placement Options

| Option | Location | Framework link |
|--------|----------|----------------|
| Embedded | `acc-governance/projects/[name]/` | Directory hierarchy (automatic) |
| Standalone | Any external path | `project.json` → `framework_source` field |

Both options produce the same state files and follow the same protocols.

---

## Owner and PM Roles

**Owner (Human):**
- Sets business goals and scope
- Approves phase advancement at Step 7 of the 8-step loop
- Makes decisions when agents disagree
- Tracks business outcomes

**PM (Claude Code AI):**
- Orchestrates agents and reviewers
- Synthesizes findings into Owner-facing summaries
- Logs all actions to PROGRESS.md
- May not act without explicit Owner instruction in the current session
