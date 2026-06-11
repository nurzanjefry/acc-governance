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

## What You Get

| Feature | Description |
|---------|-------------|
| **5-phase workflow** | Define → Spec → Build → Reconciliation → Test & Ship — each phase has defined deliverables, exit criteria, and reviewers |
| **Parallel review** | Up to 15 reviewer agents run simultaneously after each writer finishes — no waiting in line |
| **Auto revision cycles** | Writers fix reviewer blockers automatically, up to 5 rounds, before escalating to you |
| **Human approval gates** | PM stops and waits for your sign-off at every phase transition — nothing merges without you |
| **Full audit trail** | Every agent run, finding, and your decision is logged to `PROGRESS.md` and committed to git |
| **Resumable sessions** | Close the terminal, come back tomorrow — the PM reads state from files and picks up exactly where it left off |
| **Decision records** | Every architectural choice is recorded in `decisions/adr-*.md` with the reasoning, so future-you knows why |
| **Security on every phase** | `security-reviewer` runs automatically on every phase — can't be skipped |
| **Self-improving** | "Maintain" mode lets you improve the framework itself using the same 5-phase pipeline |
| **Multi-project** | One framework repo, many projects — each project links back via `project.json` |
| **Branch protection** | `master` is protected; all changes go through PRs that only you can merge |

---

## Prerequisites

- **Claude Code** — [claude.ai/code](https://claude.ai/code)
- **Git** — For version control
- **Text editor** — For reading/editing project files

### Which Claude model do you need?

**Claude Haiku is enough.** The framework is designed so Haiku handles all 30 agents efficiently — it's fast, cheap, and produces good output for structured tasks like reviewing and writing specs. You don't need Sonnet or Opus to use this. The main Claude Code session (your PM) also runs fine on Haiku.

If you want higher output quality on complex producer tasks (e.g., writing a detailed data model), switch the PM session to Sonnet. But start with Haiku — it's sufficient for most projects.

---

## Quick Start

**1. Clone and open:**
```bash
git clone https://github.com/nurzanjefry/acc-governance.git my-project
cd my-project
claude
```

**2. Choose your mode:**
- PM asks: **Use** (start a project) or **Maintain** (improve framework)?
- Pick **Use** for a new project

**3. Initialize your project:**
- PM asks: What are you building?
- Describe your product (e.g., "a PWA for food ordering with receipt reconciliation")
- PM runs `project-initializer` agent → creates `work-list.json` + `GLOSSARY.md`

**4. Review the backlog:**
- PM shows generated work items (Define → Spec → Build → Test → Ship)
- Approve or adjust the breakdown

**5. Start Phase 1:**
- PM picks first item from `work-list.json`
- Dispatches `define-author` → writes product definition
- Reviewers validate (terminology, scope, decisions)
- PM presents findings → you approve or request changes

**6. Repeat until shipped:**
- PM loops through backlog (Step 2–8 of orchestration protocol)
- You approve at each phase gate (Step 7)
- PRs auto-created → you merge on GitHub

**That's it.** PM handles orchestration, agents do the work, you make decisions.

---

## How It Works

**Your only two jobs: define the work, then approve it.**

| Step | Who | What happens |
|------|-----|--------------|
| 1. Define | You | Describe what to build — the initializer populates `work-list.json` |
| 2. Pick | PM | Selects one item from the backlog |
| 3. Write | Writer agent | Produces the deliverable for that item |
| 4. Review | Up to 15 reviewer agents (parallel) | Flag blockers, majors, minors |
| 5. Revise | Writer agent | Fixes blockers — repeated up to 5 rounds automatically |
| 6. Score | PM | Evaluates against 6-dimension rubric, prepares summary |
| 7. Approve | **You** | Read the summary, say yes or ask for changes |
| 8. Ship | git-author agent | Commits, pushes branch, opens PR — no human input needed |

Steps 2–6 and 8 run without you. You only act at steps 1 and 7.

Repeat from step 2 until the work-list is empty.

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
├── .claude/ — Agents (30 total), protocols, configurations
│   ├── agents/ — 5 project producers + 5 framework producers + 15 project reviewers + 3 framework reviewers + 1 executor + 1 initializer
│   └── docs/ — Orchestration protocol, rules, guardrails, runbooks
├── CLAUDE.md — Developer guidance for working with this framework
├── GLOSSARY.md — TEMPLATE: define your domain terms here
├── work-list.json — TEMPLATE: project backlog and deliverables
├── PROGRESS.md — Audit log of agent executions (append-only; created on first use)
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
- **Improvement pipeline:** framework-definer, framework-architect, framework-builder, framework-validator, framework-shipper

### Framework Reviewers (3) — Used in Maintain mode only
- **Governance:** framework-consistency-reviewer, backward-compatibility-reviewer, adoption-readiness-reviewer

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

See the Documentation section below for full details.

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
A: `git clone` the repo → run `claude` → Claude detects `framework.json` and enters Framework Mode → choose "Use" → it will walk you through initialization.

**Q: What if I'm already mid-project?**
A: Run `claude` → Claude detects the mode automatically → reads `PROGRESS.md` and `work-list.json` → reports current phase and next pending item.

**Q: How do I add a new phase?**
A: Create 0X-name/CLAUDE.md (exit criteria, deliverables, reviewers) + create producer agent + update orchestration-protocol.md.

**Q: My agent found a bug in the framework itself?**
A: Run `claude` → choose "Maintain" → use the `.claude/governance-improvement/` pipeline to propose, spec, build, validate, and ship the fix.

---

**Designed for high-stakes projects (finance, SaaS, compliance) where deterministic, auditable, parallel orchestration matters. For simple projects, use fewer reviewers or skip phases.**
