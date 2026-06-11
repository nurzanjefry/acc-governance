# Locking Protocol — Rules

> **Scope:** Multi-human-developer teams only. See `locking-protocol.md` for overview.

---

## Rule 1: Acquire Lock Before Starting Work

Check lock state before picking up any item:
- No lock → create new lock, proceed
- Locked by you → return `already_own`, proceed
- Locked by other, not expired → return `conflict`, wait or switch items
- Locked by other, expired → auto-release old, create new, proceed

Commit after acquiring: `git commit -m "lock: acquire spec-001 for developer@company.com"`

---

## Rule 2: Hold Lock While Working

- Lock cannot be transferred to another developer
- Lock expires after 4 hours — no manual extension
- Developer can commit multiple times while holding the lock
- Lock is tied to the work-list item, not individual commits

---

## Rule 3: Release Lock When Done

Call `pm-release-lock` when:
- Draft is complete and ready for review
- Switching to a different item
- Taking a break longer than the remaining lock time

Commit after releasing: `git commit -m "lock: release spec-001; draft complete"`
Log to PROGRESS.md: who released, when, reason, duration held.

---

## Rule 4: Auto-Cleanup on Expiration

When Developer B calls acquire_lock() on an expired item:
1. PM checks: `locked_at` timestamp > 4h ago → expired
2. PM auto-releases Developer A's lock
3. PM creates new lock for Developer B
4. PM logs expiration event to PROGRESS.md

No manual intervention needed. Prevents deadlock.

---

## Rule 5: Conflict Resolution

**Option 1 — Wait:** Let their lock expire (4h max), then acquire.
**Option 2 — Switch (recommended):** Pick a different unlocked item. Parallel work continues.
**Option 3 — Negotiate:** Contact the lock holder to release early.
**Option 4 — Escalate:** If holder is unreachable for >4h, PM can force-release with Owner approval.

First developer to acquire wins. Older lock takes precedence.
