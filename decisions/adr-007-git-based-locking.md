# ADR-007: Git-Based Locking Protocol

**Status:** Accepted  
**Date:** 2026-06-11  
**Authors:** Framework Owner  
**Supersedes:** —

---

## Context

When multiple agents or human operators work on the same project simultaneously, concurrent writes to shared files (PROGRESS.md, work-list.json, GLOSSARY.md) can cause conflicts. The framework needs a locking strategy that:

- Prevents concurrent modification of shared state files
- Works without an external lock service (consistent with ADR-002: file-based state)
- Is simple enough for stateless agents to follow

## Decision

Use **git as the synchronization primitive** for shared file writes:

1. PM waits for a clean `git status` before updating any shared tracking file
2. Agents commit their deliverables to a feature branch before PM reads their output
3. A clean working tree is the "agent finished" signal — no polling, no lock files
4. PM executes all writes to shared files (PROGRESS.md, work-list.json, GLOSSARY.md) in a separate commit after the agent's feature commit

This extends the PM-sole-writer model (ADR-005) with a concrete synchronization mechanism.

## Scope

This locking protocol is **scoped to single-session usage with a human PM**. It is sufficient because:
- The PM is the only writer to shared files (ADR-005)
- Agents write only to their phase folder (agent isolation rule)
- One task is in-progress at a time (work-list single-active-item rule)

For **multi-human team scenarios** (multiple humans running PM sessions concurrently), a more formal locking mechanism (e.g., a `lock/` directory with per-file lock files, or branch-per-agent strategy) would be needed. This is deferred to a future ADR.

## Consequences

**Positive:**
- Zero external dependencies — git is always available
- Objective "finished" signal that doesn't require agent cooperation
- Aligns with existing git workflow (every agent commits their work)
- Simple protocol agents can follow without special logic

**Negative:**
- Doesn't scale to concurrent human operators without extension
- Git must be initialized in the project (already required by ADR-002)

## Related

- ADR-002: File-Based State (git as the state store)
- ADR-003: PM as Sole Orchestrator (single active PM)
- ADR-005: PM Sole Writer (who writes what)
- `.claude/docs/locking-protocol.md` — operational runbook for conflict recovery
- `.claude/docs/orchestration-protocol.md` — Synchronization & Ownership section
