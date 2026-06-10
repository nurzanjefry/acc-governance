# acc-governance (Agent Control Center Governance)

**A fully-agentic, deterministic project management framework for end-to-end product creation, development, and orchestration through 5 phases: Define → Spec → Build → Reconciliation → Test & Ship.**

---

## Role Definition

**Project Manager (PM):** Claude Code
- Execute orchestration protocol, manage agents, synthesize findings, present to Owner

**Owner/Executive:** You
- Define objectives, approve phase advancement, make strategic decisions

**Workers:** 22 AI Agents
- Execute assigned work, conduct peer review, commit to version control

See `CLAUDE.md` and `.claude/docs/ROLES.md` for formal role definitions and governance structure.

---

## Prerequisites

- **Claude Code** — [claude.ai/code](https://claude.ai/code)
- **Git** — For version control
- **Text editor** — For reading/editing project files

---

## Quick Start

**1. Copy the framework:**
```bash
git clone <repo-url> my-project
cd my-project
```

**2. Read CLAUDE.md** (explains PM role + how to set up):
```bash
# Open CLAUDE.md — it has full startup instructions
```

**3. Update project files for your domain:**
- `GLOSSARY.md` — Add your domain terminology
- `work-list.json` — Define your deliverables (or let project-init populate it)
- Phase `CLAUDE.md` files — Customize exit criteria if needed

**4. Open in Claude Code:**
```bash
claude-code
```
I (Claude Code) am your Project Manager. I'll orchestrate the 8-step loop and ask you for approval on business decisions. Follow CLAUDE.md's "Welcome, Project Manager" section.

---

## How It Works

**Three-layer execution model:**

| Layer | Actor | Function |
|-------|-------|----------|
| **Strategic** | Owner | Define objectives, approve phase advancement, authorize decisions |
| **Operational** | Claude PM | Execute 8-step loop, manage agents, synthesize quality findings |
| **Execution** | 22 Agents | Write deliverables, conduct peer review, commit output |

**Per work-list item, PM executes:**
1. Orient — Read work-list.json, PROGRESS.md, phase CLAUDE.md
2. Pick — Select one not_started item; set in_progress
3. Choose — Route to appropriate producer agent
4. Brief — Provide item, exit criteria, context files
5. Review — Dispatch 15 reviewers in parallel (6 quality dimensions)
6. Revise — Synthesize findings; brief agent for batch revision (max 5 cycles)
7. Score & Gate — Present to Owner for approval
8. Close Out — Mark item passing; update tracking; log to PROGRESS.md

**State lives in git (resumable, auditable):**
- `work-list.json` — Backlog + item status
- `PROGRESS.md` — Audit log of every execution
- `decisions/adr-*.md` — Architectural decisions (why choices were made)
- `GLOSSARY.md` — Canonical terminology

---

## Framework Structure

```
acc-governance/
├── 01-define/ — Product definition (prd, user journey, UI/UX, roles)
├── 02-spec/ — Technical architecture (stack, data model, API, standards)
├── 03-build/ — Implementation (code, database, integration)
├── 04-reconciliation/ — Domain logic validation (if needed)
├── 05-test-ship/ — Testing & deployment (test plan, tracking, runbooks)
├── decisions/ — ADR templates and architectural decision records
├── .claude/ — Agents (22 total), protocols, configurations
│   ├── agents/ — 5 producers + 15 reviewers + 1 executor + 1 project-init
│   └── docs/ — Orchestration protocol, rules, guardrails, runbooks
├── CLAUDE.md — Developer guidance for working with this framework
├── GLOSSARY.md — TEMPLATE: define your domain terms here
├── work-list.json — TEMPLATE: project backlog and deliverables
├── PROGRESS.md — TEMPLATE: audit log of agent executions
└── README.md — This file
```

---

## The 22 Agents

### Producers (One per Phase)
- **define-author** — Phase 1 (product definition)
- **spec-author** — Phase 2 (technical architecture)
- **build-author** — Phase 3 (implementation)
- **reconciliation-author** — Phase 4 (domain logic)
- **ship-author** — Phase 5 (testing & deployment)

### Specialist Reviewers (15 Total)
Run in parallel after each producer finishes.

**Correctness Dimension:**
- terminology-reviewer, scope-reviewer, decisions-reviewer

**Design Quality:**
- architecture-reviewer, data-model-reviewer, security-architect

**Quality Attributes:**
- test-strategy-reviewer, performance-reviewer, observability-architect

**Operational:**
- api-contract-reviewer, infrastructure-reviewer, monitoring-reviewer, tech-debt-reviewer

**Documentation:**
- docquality-reviewer

**Permanent (Every Phase):**
- security-reviewer ★ (secret scan + design review)

### Executor
- **git-author** — Handles commits/PRs (only after security approval)

---

## The 8-Step PM Loop

1. **Orient** — Understand the task
2. **Pick** — Choose one work-list item
3. **Choose worker** — Select producer agent (define/spec/build/etc.)
4. **Brief & dispatch** — Give producer the item + exit criteria
5. **Review** — Run all relevant reviewers in parallel
6. **Revise** — Producer fixes blocker/major findings (max 5 cycles)
7. **Score & gate** — Rubric: 6 dimensions, 0–2 scoring, max 12 points
8. **Close out** — Mark item passing, log to PROGRESS.md

See `.claude/docs/orchestration-protocol.md` for full details.

---

## Documentation

**Start here:**
- **CLAUDE.md** — Your PM role + how to start + architecture overview
- **GLOSSARY.md** — Template for domain terms

**For running projects:**
- **01-define/CLAUDE.md, 02-spec/CLAUDE.md, etc.** — Phase deliverables + exit criteria + reviewers
- **.claude/docs/orchestration-protocol.md** — Full 8-step PM loop specification
- **.claude/agents/README.md** — Agent registry + reviewer matrix

**For evolving the framework:**
- **.claude/docs/FRAMEWORK-EVOLUTION.md** — RFC process for framework changes
- **.claude/docs/rules.md** — Core constraints
- **.claude/docs/guardrails.md** — Restricted actions (no force-push, no skipping security, etc.)

---

## Customization

The framework is generic. For your project:
- **Add domain reviewers** (e.g., ML-reviewer, compliance-reviewer)
- **Adjust phases** (5 is default; add/remove as needed)
- **Override exit criteria** (edit phase CLAUDE.md)
- **Customize templates** (templates in each phase folder are starting points)

See CLAUDE.md § "Development Guidelines" for how.

---

## Common Questions

**Q: How do I start a brand new project?**
A: Copy acc-governance/ → Open CLAUDE.md → Follow "Welcome, PM" section → It will ask for project name + domain.

**Q: What if I'm already mid-project?**
A: Read CLAUDE.md, read latest PROGRESS.md entry, read your work-list.json, follow 8-step PM loop starting at "Pick One Item".

**Q: How do I add a new phase?**
A: Create 0X-name/CLAUDE.md (exit criteria, deliverables, reviewers) + create producer agent + update orchestration-protocol.md.

**Q: My agent found a bug in the framework itself?**
A: Use governance-framework-improvement/ parallel pipeline to propose + test + ship improvements.

---

**Designed for high-stakes projects (finance, SaaS, compliance) where deterministic, auditable, parallel orchestration matters. For simple projects, use fewer reviewers or skip phases.**
