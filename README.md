# acc-governance (Agent Control Center Governance)

**A reusable, deterministic project management framework for guiding teams through product definition, specification, implementation, domain logic validation, and deployment.**

Not project-specific. Use this as a template for new projects.

---

## How to Use This Framework

### For a New Project

Copy `acc-governance/` to `projects/my-project/`, then:
```
cd projects\my-project
init.bat
```

This pre-populates the project with base structure (5 phases, work-list.json, PROGRESS.md).

Then:
```
claude-code agent project-init --project my-project
```

The project-init agent will:
1. Prompt for project name, domain, description
2. Ask for initial glossary terms + definitions
3. Pre-populate GLOSSARY.md and work-list.json
4. Offer to start define-author immediately

---

## Framework Structure

```
acc-governance/
├── init.bat — Initialize new projects (run from within copied folder)
├── 01-define/ — Product definition (prd, user journey, UI/UX, roles)
├── 02-spec/ — Technical architecture (stack, data model, API, standards)
├── 03-build/ — Implementation (code, database, integration)
├── 04-reconciliation/ — Domain logic validation (if needed)
├── 05-test-ship/ — Testing & deployment (test plan, tracking, runbooks)
├── decisions/ — ADR templates and framework governance
├── .claude/ — Agents (22 total), protocols, configurations
│   ├── agents/ — 5 producers + 15 reviewers + 1 executor + 1 project-init
│   └── docs/ — Orchestration protocol, rules, guardrails, runbooks
├── CLAUDE.md — Framework governance rules (not project-specific)
├── GLOSSARY.md — TEMPLATE: define your domain terms here
└── README.md — This file
```

---

## The 21 Agents

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

---

## Key Protocols

**Orchestration:** `.claude/docs/orchestration-protocol.md` — Full 8-step PM loop with synchronization strategy

**Revision Cycle:** How producers batch findings and fix once (not per finding)

**Error Recovery:** `.claude/docs/error-recovery-runbook.md` — What to do if a producer/reviewer fails

**Locking:** `.claude/docs/locking-protocol.md` — Prevent concurrent edit conflicts in work-list.json

**Framework Evolution:** `.claude/docs/FRAMEWORK-EVOLUTION.md` — RFC process for improving the framework itself

---

## State Management

**All state lives in files (not in memory):**

- `work-list.json` — Backlog of deliverables (status, owner, verification)
- `PROGRESS.md` — Running log of every agent execution (audit trail)
- `decisions/adr-*.md` — Recorded architectural decisions (why choices made)
- `GLOSSARY.md` — Canonical domain terminology (single source of truth)

**Why files?**
- Human-readable (git shows every change)
- Session-reset resilient (pull git, resume)
- Auditable (full history in git)
- No database dependency

---

## Starting a New Project

**Option A: Automated (Recommended)**

Copy `acc-governance/` to `projects/my-project/`, then:
```
cd projects\my-project
init.bat
```

This pre-populates the project with base structure (5 phases, work-list.json, PROGRESS.md).

Then:
```
claude-code agent project-init --project my-project
```

The project-init agent will:
1. Prompt for project name, domain, description
2. Ask for initial glossary terms + definitions
3. Pre-populate GLOSSARY.md and work-list.json
4. Offer to start define-author immediately

---

**Option B: Manual**

1. Copy `governance-framework/` to `projects/my-project/`
2. Read `projects/my-project/CLAUDE.md` (framework rules)
3. Update `projects/my-project/GLOSSARY.md` with your domain terms
4. Update `projects/my-project/work-list.json` (customize phases if needed)
5. Run `define-author` agent on item `def-001`
6. Follow the orchestration loop (review → revise → pass → next phase)

---

## Customization

This framework is generic. Customize for your project:

- **Add domain-specific reviewers** (e.g., ML-reviewer for ML projects, compliance-reviewer for regulated domains)
- **Adjust phases** (some projects need 6 phases; others are fine with 4)
- **Adjust templates** (templates in each phase folder are starting points, not requirements)
- **Adjust exit criteria** (each phase CLAUDE.md lists defaults; override if needed)

---

## Documentation

**For framework users:**
- `01-define/CLAUDE.md` — What Phase 1 producers/reviewers do
- `02-spec/CLAUDE.md` — What Phase 2 producers/reviewers do
- `.claude/docs/orchestration-protocol.md` — How PM loop works
- `.claude/agents/README.md` — Agent registry and evaluation matrix

**For framework maintainers:**
- `.claude/docs/FRAMEWORK-EVOLUTION.md` — How to evolve the framework
- `.claude/docs/rules.md` — Core framework rules and constraints
- `.claude/docs/guardrails.md` — Actions requiring explicit approval

---

## Questions?

- How do I add a new phase? → Edit `.claude/docs/orchestration-protocol.md` and add phase CLAUDE.md
- How do I create a new agent? → Copy an existing agent's format, update `.claude/agents/README.md`
- How do I customize exit criteria? → Edit the phase CLAUDE.md file
- How do I track progress? → Log to PROGRESS.md after each review cycle

---

**This framework is designed for high-stakes projects (finance, SaaS, compliance).** For simple projects or MVPs, use fewer reviewers or skip phases.
