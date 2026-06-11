# ADR-005: PM as Sole Writer to Shared Files

**Date:** 2026-06-11
**Status:** Accepted
**Deciders:** Framework Owner

---

## Context

When multiple agents run in parallel (15 reviewers after each producer), they may need to update shared files like `PROGRESS.md`, `work-list.json`, and reference indexes. Allowing agents to write these files directly creates concurrent write conflicts. The framework needed a concurrency model that eliminates this class of conflict entirely.

---

## Decision

PM is the sole writer to all shared files. Agents write only to their assigned phase folder output files. When done, agents return a JSON summary to PM declaring what they produced and what references need updating. PM collects all agent JSONs, then writes to shared files in a single sequential pass.

Shared files: `PROGRESS.md`, `work-list.json`, `GLOSSARY.md`, `project-context.md`, and any reference or index file.

---

## Rationale

- **Eliminates concurrent write conflicts entirely:** If only one entity writes to shared files, concurrent conflict is impossible by construction — not by coordination.
- **Single audit point:** All state changes to shared files flow through PM. If a shared file has unexpected content, PM is the only place to investigate.
- **Simpler agent contracts:** Agents don't need to know about locking, retries, or conflict resolution. They just produce output and return JSON.
- **Forces explicit declaration:** Agents must declare what they created and what should be linked. This surfaces reference updates that would otherwise be forgotten.

---

## Alternatives Considered

- **File locking per agent:** Agents acquire a lock before writing, release when done. Rejected — lock acquisition adds latency, lock expiry logic adds complexity, lock failures require retry logic.
- **Append-only shared files with merge:** Agents append freely, PM merges. Rejected — concurrent appends still conflict; merge logic for structured files (JSON) is fragile.
- **Each agent owns its own state file:** No shared files. Rejected — PM needs a single authoritative backlog and log to orchestrate across agents.

---

## Consequences

**Positive:**
- Zero concurrent write conflicts regardless of how many agents run in parallel
- All shared file writes are intentional and traceable to PM actions
- Agents have a simpler contract: produce output, return JSON, stop

**Negative:**
- PM becomes a write bottleneck — all shared file updates wait for PM's sequential pass
- Agents cannot self-log; they depend on PM to record their work (mitigated by `references_to_update` field in JSON summary)

---

## References

- `.claude/docs/rules.md` — Agent concurrency model rule
- `.claude/docs/guardrails.md` — Rules 9, 10 (PM-owned files)
- `.claude/agents/output-format.md` — `references_to_update` field
- `ADR-001` — Stateless agents (companion decision)
- `ADR-002` — File-based state (companion decision)
