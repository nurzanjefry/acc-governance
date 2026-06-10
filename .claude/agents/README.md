# Governance Framework Agent Pipeline

Custom subagents that drive a **producer → review → fix** loop, scoped to the phase you're working in. The main Claude session (PM) orchestrates: it runs producers, fans outputs to reviewers in parallel, synthesizes findings, applies fixes, and asks you to approve.

**Supports any project.** This is a reusable framework with 22 agents (5 producers + 15 reviewers + 1 executor + 1 project initializer).

---

## Quick Links

**For agents:**
- [Agent rules](../docs/rules.md) — what you can do, what requires approval, JSON output format
- [Output format](output-format.md) — JSON schema agents must return when done
- [Guardrails](../docs/guardrails.md) — restricted actions (secrets, scope, git, PII, external services)

**For the PM (main session):**
- [Orchestration protocol](../docs/orchestration-protocol.md) — the 8-step loop (orient → pick → brief → review → revise → score → gate → close out)

---

## Roles

**Producers** (one per phase — write files within their phase folder):

| Agent | Phase | Owns |
|---|---|---|
| `define-author` | 1 | `01-define/` — product definition, journey, UI/UX |
| `spec-author` | 2 | `02-spec/` — tech spec, stack, data model, receipt pipeline, standards |
| `build-author` | 3 | `03-build/` — build order, implementation |
| `reconciliation-author` | 4 | `04-reconciliation/` — finance model, matching rules |
| `ship-author` | 5 | `05-test-ship/` — test plan, tracking, deployment |
| `framework-definer` | 1 (governance-improvement) | `governance-framework-improvement/01-framework-define/` — flaw analysis, philosophy, roadmap |
| `framework-architect` | 2 (governance-improvement) | `governance-framework-improvement/02-framework-spec/` — 7 detailed specs |
| `framework-builder` | 3 (governance-improvement) | `governance-framework-improvement/03-framework-build/` — implementations |
| `framework-validator` | 4 (governance-improvement) | `governance-framework-improvement/04-framework-validation/` — testing |
| `framework-shipper` | 5 (governance-improvement) | `governance-framework-improvement/05-framework-ship/` — migration, adoption |

**Reviewers** (shared, read-only, report findings):

| Reviewer | Checks |
|---|---|
| `terminology-reviewer` | Terms match `GLOSSARY.md`; new concepts added there first |
| `scope-reviewer` | Output serves 9-step flow + product definition; no drift, gaps, or contradictions |
| `architecture-reviewer` | System design, data flows, tech stack alignment, RBAC/multi-tenancy consistency, scalability patterns |
| `data-model-reviewer` | Schema correctness, normalization, constraints, indexes, financial data integrity, audit logging design |
| `security-reviewer` ★ | Operational security: secret scan (hard gate before any commit/push), RBAC enforcement, audit logging, PII handling |
| `security-architect` | Design-time security: threat modeling, cryptographic patterns, access control design, API attack vectors, data protection |
| `test-strategy-reviewer` | Testability of architecture, critical test paths (14 scenarios), test coverage strategy, test infrastructure alignment |
| `observability-architect` | Logging & tracing strategy, error instrumentation, agentic debugging support, cost tracking, operational runbooks |
| `tech-debt-reviewer` | Tech debt markers, ADR coverage, age & accumulation, risk assessment, remediation tracking, metadata quality |
| `api-contract-reviewer` | REST API design, backwards compatibility, versioning strategy, request/response contracts, RBAC scoping |
| `infrastructure-reviewer` | Deployment strategy, backup/disaster recovery, reliability, cost efficiency, operational documentation |
| `performance-reviewer` | Query optimization, endpoint latency targets, bottleneck detection, scaling assumptions, instrumentation |
| `monitoring-reviewer` | SLOs/SLIs, health checks, alert rules, incident runbooks, on-call procedures, cost tracking |
| `docquality-reviewer` | Cross-refs resolve, no duplication, templates filled, PROGRESS.md logged |
| `decisions-reviewer` | Architectural/scope choices recorded as ADRs in `decisions/` |
| `framework-consistency-reviewer` | (governance-improvement) Improvements honor core principles (state-in-files, stateless agents, deterministic loops) |
| `backward-compatibility-reviewer` | (governance-improvement) Changes don't break existing projects; old projects still work; zero forced migration |
| `adoption-readiness-reviewer` | (governance-improvement) Improvements are documented and adoptable; no expert hand-holding needed |

(★ = permanent, never dropped)

---

## Reviewer Matrix by Phase

| Phase | Reviewers |
|---|---|
| 1 Define | security ★, terminology ✓, scope ✓, docquality ✓, decisions ◦ |
| 2 Document | security ★, security-architect ✓, data-model ✓, test-strategy ✓, observability ✓, api-contract ✓, terminology ✓, scope ✓, architecture ✓, docquality ✓, decisions ✓ |
| 3 Build | security ★, security-architect ✓, data-model ✓, test-strategy ✓, observability ✓, tech-debt ✓, api-contract ✓, performance ✓, architecture ✓, code ✓, terminology ✓, scope ✓, docquality ✓, decisions ✓ |
| 4 Finance | security ★, security-architect ✓, data-model ✓, test-strategy ✓, observability ✓, tech-debt ✓, architecture ✓, terminology ✓, scope ✓, docquality ✓, decisions ✓ |
| 5 Test & ship | security ★, security-architect ✓, data-model ◦ (test fixtures), test-strategy ✓, observability ✓, tech-debt ✓, infrastructure ✓, monitoring ✓, performance ✓, scope ✓ (PWA), docquality ✓, decisions ◦ |
| 6+ Maintenance | security ★, observability ✓, tech-debt ✓ (monthly), api-contract ✓, infrastructure ✓, monitoring ✓, performance ✓ |

Legend: ✓ = always, ◦ = if a decision was made or applies, ★ = permanent

---

## Key Rules

**Agents:**
- Return a JSON summary when done (see `output-format.md`)
- Stay within your phase folder (except appending to PROGRESS.md, adding to GLOSSARY.md, updating your work-list items)
- Never delete files, edit outside your phase, commit, or run destructive shell commands without approval

**PM:**
- Follow the 8-step loop in `orchestration-protocol.md`
- Spot-check agent files, dispatch reviewers in parallel, synthesize findings
- Run revision loop if reviewers flag changes (up to 5 rounds)
- Stop at human approval gate before marking items `passing`

**Guardrails:**
- See `../docs/guardrails.md` for complete list of restricted actions
- Root `CLAUDE.md` and root `README.md` have pointers to these docs

---

## State & Tracking

- **`work-list.json`** — forward-looking backlog (status, verification, evidence)
- **`PROGRESS.md`** — backward-looking log (one entry per run, what was done, evidence, next steps)
- **`logs/<item-id>.md`** — session log (gitignored; PM writes this during a run to capture agent outputs, reviewer verdicts, human approvals)

---

## Git & Merge

After an item is marked `passing`:

1. **Gate 2 — staging plan:** PM shows human: branch, files, commit message. Wait for approval.
2. **Gate 3 — merge:** `git-author` creates branch, commits, pushes, opens PR. Human merges on GitHub (nothing lands on `main` without a PR).

See `../docs/guardrails_git.md` for commit message format and branch naming.

---

## System-Enforced Secret Scan

A tracked git hook (`.githooks/pre-commit`) runs on every commit and blocks high-confidence credential patterns. Enable once per clone: `git config core.hooksPath .githooks`.

The `security-reviewer` agent is the deeper, design-aware layer above the hook.

---

## Note

For detailed playbook — how PM orchestrates each run, how the revision loop works, how the human approval gate works — see `../docs/orchestration-protocol.md`.
