# acc-governance

**A framework that turns Claude Code into your AI project manager.**

You describe what you want to build. Claude Code runs a team of 30 AI agents — writers, reviewers, and a git executor — to produce specs, code, and decisions across 5 phases. At every key decision, it stops and asks for your approval before moving on.

Everything is tracked in plain files committed to git, so the project is always resumable, auditable, and yours.

---

## Who does what

| Role | Who | What they do |
|------|-----|--------------|
| **You (Owner)** | Human | Describe what to build, approve work, make calls when agents disagree |
| **PM** | Claude Code | Runs the agents, synthesizes findings, presents decisions for your approval |
| **Workers** | 30 AI agents | Write deliverables, review each other's work, commit to git |

You stay in control. The PM never merges code, never spends your approval on something you haven't seen, and stops at every gate until you say go.

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
claude
```
Claude Code is your PM. It will detect `framework.json`, greet you as framework maintainer, and ask whether you want to Use or Maintain the framework. Follow its prompts — CLAUDE.md drives the startup flow.

---

## How It Works

**You define the work. The PM runs it.**

1. You add items to `work-list.json` (or let the initializer populate it from your description)
2. The PM picks one item at a time, sends it to the right writer agent, then fans out to up to 15 reviewer agents in parallel
3. Reviewers flag blockers — the writer fixes them (up to 5 rounds)
4. The PM scores the result and **stops for your approval**
5. Once you approve, git-author commits and opens a PR — you merge on GitHub

Repeat until the work-list is empty.

**Nothing gets lost between sessions.** All state lives in committed files:
- `work-list.json` — what's done, what's next, what's blocked
- `PROGRESS.md` — full audit log of every agent run
- `decisions/adr-*.md` — why choices were made
- `GLOSSARY.md` — canonical terminology for your domain

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
│   ├── agents/ — 10 producers + 18 reviewers + 1 executor + 1 initializer (30 total)
│   └── docs/ — Orchestration protocol, rules, guardrails, runbooks
├── CLAUDE.md — Developer guidance for working with this framework
├── GLOSSARY.md — TEMPLATE: define your domain terms here
├── work-list.json — TEMPLATE: project backlog and deliverables
├── PROGRESS.md — TEMPLATE: audit log of agent executions
└── README.md — This file
```

---

## The 30 Agents

### Project Producers (5) — One per phase
- **define-author**, **spec-author**, **build-author**, **reconciliation-author**, **ship-author**

### Project Reviewers (15) — Run in parallel after each producer
- **Correctness:** terminology-reviewer, scope-reviewer, decisions-reviewer
- **Design quality:** architecture-reviewer, data-model-reviewer, security-architect
- **Quality attributes:** test-strategy-reviewer, performance-reviewer, observability-architect
- **Operational:** api-contract-reviewer, infrastructure-reviewer, monitoring-reviewer, tech-debt-reviewer
- **Documentation:** docquality-reviewer
- **Permanent (every phase):** security-reviewer ★

### Framework Producers (5) — Used in Maintain mode only
- **framework-definer**, **framework-architect**, **framework-builder**, **framework-validator**, **framework-shipper**

### Framework Reviewers (3) — Used in Maintain mode only
- **framework-consistency-reviewer**, **backward-compatibility-reviewer**, **adoption-readiness-reviewer**

### Executor & Initializer (2)
- **git-author** — Handles commits/PRs (only after security approval)
- **project-initializer** — Bootstraps new projects from the framework template

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

See `.claude/docs/use-mode.md` (for project-level changes) or `.claude/docs/maintain-mode.md` (for framework-level changes).

---

## Common Questions

**Q: How do I start a brand new project?**
A: Copy acc-governance/ → run `claude` → Claude detects `framework.json` and enters Framework Mode → choose "Use" → it will walk you through initialization.

**Q: What if I'm already mid-project?**
A: Run `claude` → Claude detects the mode automatically → reads `PROGRESS.md` and `work-list.json` → reports current phase and next pending item.

**Q: How do I add a new phase?**
A: Create 0X-name/CLAUDE.md (exit criteria, deliverables, reviewers) + create producer agent + update orchestration-protocol.md.

**Q: My agent found a bug in the framework itself?**
A: Run `claude` → choose "Maintain" → use the `.claude/governance-improvement/` pipeline to propose, spec, build, validate, and ship the fix.

---

**Designed for high-stakes projects (finance, SaaS, compliance) where deterministic, auditable, parallel orchestration matters. For simple projects, use fewer reviewers or skip phases.**
