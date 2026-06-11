# FAQ — acc-governance Framework

## What is acc-governance?
A framework for building and shipping software projects through structured phases (Define, Spec, Build, Reconciliation, Test & Ship). It enforces governance through state files, agents, and reviewer workflows.

## Who should use it?
Teams building a new project who want:
- Clear decision points and audit trails
- Parallel review and quality gates
- Reusable templates and protocols

## How do I start?
1. **If this IS the framework:** Run `/init` to set it up.
2. **If you want a new project:** Choose embedded (create inside framework) or standalone (external directory).
3. **If you're linking an existing project:** Provide the project path — I'll detect the structure and create the link.

## What are the main files?
- `framework.json` — framework identity (in framework repo only)
- `project.json` — project identity and framework link
- `project-context.md` — what exists, scope, decisions
- `work-list.json` — backlog with status and ownership
- `PROGRESS.md` — append-only audit log
- `GLOSSARY.md` — shared domain terminology
- `decisions/adr-*.md` — architectural decisions

## How does a project flow?
Each work item follows an 8-step loop: Orient → Pick → Choose worker → Brief → Review → Revise → Gate (Owner approval) → Close out.

## Can I customize it?
Yes. Update `GLOSSARY.md` for domain terms, add custom reviewers to phase CLAUDE.md files, adjust exit criteria per phase.

## What if I have questions mid-project?
Check the phase CLAUDE.md for that phase — it has exit criteria and reviewer roles. See `.claude/docs/orchestration-protocol.md` for the full loop.
