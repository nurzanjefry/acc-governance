# ADR-004: Five-Phase Model — Why These Phases and These Boundaries

**Date:** 2026-06-11
**Status:** Accepted
**Deciders:** Framework Owner

---

## Context

The framework needed to divide product work into phases with clear handoff boundaries. The question was how many phases, what each covers, and where the boundaries fall. Too few phases merges concerns that should be separated; too many creates unnecessary overhead.

---

## Decision

Five phases: Define → Spec → Build → Reconciliation → Test & Ship. Each phase has one producer agent, its own CLAUDE.md with exit criteria, and a dedicated template set. Phase boundaries are approval gates — Owner must approve before advancement.

---

## Rationale

**Why five and not four:**
- Reconciliation (Phase 4) exists because domain-specific logic validation (finance rules, matching algorithms, business invariants) is consistently skipped or rushed when bundled with Build. Separating it forces explicit validation before shipping.

**Why these boundaries:**
- **Define → Spec:** Separates "what" from "how". No technical decisions until the product is unambiguous.
- **Spec → Build:** Separates architecture from implementation. No code until the design is reviewed.
- **Build → Reconciliation:** Separates generic implementation from domain logic. Business rules get their own validation pass.
- **Reconciliation → Test & Ship:** Separates logic validation from operational readiness. Deployment and monitoring are distinct concerns.

**Why each phase has its own CLAUDE.md:**
- Exit criteria vary per phase. A generic "done" definition fails — Phase 1 done means something different from Phase 3 done.
- Reviewer sets differ per phase. Security is always present; API contract review only matters when there's an API.

---

## Alternatives Considered

- **Three phases (Define, Build, Ship):** Simpler. Rejected — Spec and Reconciliation are consistently the phases where hidden assumptions cause expensive rework if skipped.
- **Seven phases:** More granular handoffs. Rejected — overhead outweighs benefit for most projects; framework becomes too rigid for small teams.
- **No phases, continuous flow:** Single backlog, no phase gates. Rejected — removes the human approval gate that is the core governance mechanism.

---

## Consequences

**Positive:**
- Each phase has a clear producer, clear deliverables, clear exit criteria
- Domain logic gets an explicit validation pass (Phase 4) before shipping
- Owner approval gate at each boundary prevents drift from business intent

**Negative:**
- Phase 4 (Reconciliation) may be unnecessary for non-domain-heavy projects — teams can defer it by marking items as `status: deferred` in work-list.json
- Five approval gates add friction for fast-moving projects

---

## References

- `CLAUDE.md` — Architecture Overview, Five Phases
- `01-define/CLAUDE.md` through `05-test-ship/CLAUDE.md` — per-phase exit criteria
