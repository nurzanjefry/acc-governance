# ADR-008: RFC-Based Framework Evolution Model

**Status:** Accepted  
**Date:** 2026-06-11  
**Authors:** Framework Owner  
**Supersedes:** —

---

## Context

After v1.0, the framework will need to evolve: new reviewers, updated protocols, changed phase structure, and new governance requirements. Without a formal process, changes risk:

- Breaking backward compatibility for projects already using the framework
- Adding features without data justification (reactive vs. evidence-based)
- Losing audit trail of why the framework changed

## Decision

All non-trivial framework changes go through an **RFC (Request for Comments) process**:

1. **Trigger:** A quantitative signal (recurring blocker, slow phase, low convergence, budget overrun, new compliance) justifies the RFC — not opinion alone
2. **Draft:** RFC author writes `RFC-{NUMBER}-{TITLE}.md` with problem statement (data required), proposed solution, cost/benefit, and backward-compatibility analysis
3. **Review:** Governance committee (5 members, 4/5 quorum, bi-weekly meetings) approves, defers, or rejects
4. **Implementation:** Approved RFCs enter the governance-improvement pipeline (same 5-phase model used for the framework itself)
5. **Backward compatibility guarantee:** Existing projects stay on their pinned `framework_version`; migration is opt-in

## Why RFC over ad-hoc changes

- **Deterministic:** Every change has a documented trigger, decision, and rationale
- **File-based:** RFC documents live in `governance-improvement/rfcs/` — consistent with ADR-002
- **Committee governance:** No single person can change the framework unilaterally
- **Evidence-based:** Trigger threshold rules prevent speculative changes

## Scope of RFC requirement

**Requires RFC:** Agent definition changes, phase structure changes, schema changes to work-list.json or PROGRESS.md, adding/removing reviewers, changing the 8-step PM loop.

**Does NOT require RFC:** Documentation fixes, typo corrections, adding examples, updating file paths.

## Consequences

**Positive:**
- Framework evolution is traceable, reversible, and evidence-based
- Backward compatibility is guaranteed by policy
- Committee governance prevents framework drift from personal preferences

**Negative:**
- Slower iteration (bi-weekly review cycle)
- RFC process adds overhead for urgent fixes (mitigated: doc fixes bypass RFC)

## Related

- ADR-002: File-Based State (RFC documents are files)
- `.claude/docs/FRAMEWORK-EVOLUTION.md` — living policy document
- `.claude/governance-improvement/02-framework-spec/fspec-007-framework-evolution.md` — full specification
