# Locking Protocol — Troubleshooting

> **Scope:** Multi-human-developer teams only. See `locking-protocol.md` for overview.

---

## "Item locked by developer-a until 13:00"

You want to work on this item but it is held by someone else.

1. **Wait** — lock expires in ≤4h, then acquire
2. **Switch** — pick a different unlocked item (recommended)
3. **Negotiate** — ask the holder to release early
4. **Escalate** — if holder is unreachable, contact PM to force-release with Owner approval

---

## "You don't own the lock on this item"

You tried to release a lock you don't hold.

Cause: lock expired and was reassigned, or someone else holds it.
Fix: run `pm-lock-status` to see who owns it, then wait or switch items.

---

## "Lock expired while I was still working"

Your lock expired before you finished.

Fix: call `pm-acquire-lock` again immediately to re-acquire.
If someone else already acquired it, coordinate — negotiate who continues.

---

## Merge Conflict in work-list.json

Two developers pushed changes to the same item simultaneously.

1. Check `locked_at` timestamps — older lock wins
2. Developer with newer lock rebases, takes the older lock's version
3. If conflict looks like a bug (locking was correct), flag to PM

---

## Deadlock (Lock Not Releasing)

Lock held by a developer who has disappeared.

Automatic: lock expires after 4h, next acquire_lock() auto-cleans.
Manual escalation: provide item ID and lock holder to PM — PM force-releases with Owner approval.
