# ADR-002: File-Based State — Git as the Source of Truth

**Date:** 2026-06-11
**Status:** Accepted
**Deciders:** Framework Owner

---

## Context

The framework needed a mechanism to persist state across sessions, agents, and team members. Options included an external database, an API service, an in-memory store, or plain files in a git repository.

---

## Decision

All state lives in git-tracked files. No external database, no API, no in-memory store. The canonical state files are: `work-list.json`, `PROGRESS.md`, `GLOSSARY.md`, `project.json`, `project-context.md`, and `decisions/adr-*.md`.

---

## Rationale

- **Zero infrastructure:** No server, no database credentials, no network dependency. The framework works offline and in any environment that has git.
- **Auditability:** Every state change is a git commit with a message, author, and timestamp. Full history is always available.
- **Portability:** A project is fully self-contained in its folder. Clone it, zip it, copy it — state comes with it.
- **Conflict resolution:** Git's merge tools handle concurrent edits. No custom conflict resolution logic needed.
- **Human-readable:** Any team member can open `PROGRESS.md` or `work-list.json` in a text editor and understand the current state without special tools.

---

## Alternatives Considered

- **External database (PostgreSQL, SQLite):** Rich querying, transactions. Rejected — requires infrastructure, breaks portability, adds ops burden.
- **JSON API service:** Centralized state with versioning. Rejected — network dependency, auth complexity, single point of failure.
- **In-memory PM context:** PM holds all state in conversation context. Rejected — lost on session reset, not shareable across team members.

---

## Consequences

**Positive:**
- Framework works in any environment with git
- Full audit trail of every decision and state change
- State is always human-readable and inspectable

**Negative:**
- Concurrent writes to the same file require coordination (resolved by PM-sole-writer rule — see ADR-005)
- Large projects with many work items may cause work-list.json to grow unwieldy (mitigation: archive completed items)

---

## References

- `CLAUDE.md` — State Files table
- `ADR-005` — PM sole writer rule (companion decision)
- `.claude/docs/orchestration-protocol.md` — State lives in files, not agents
