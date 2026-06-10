# Session Wrap-Up Checklist

**When:** End of every PM session (after agents complete work and human approves)

**Why:** Ensure work is logged, tracked, and saved remotely before context resets.

---

## Pre-Session (Before Starting)

- [ ] Read `work-list.json` — what's in_progress?
- [ ] Read latest `PROGRESS.md` entry — what was the last state?
- [ ] Run `git status` — are there uncommitted changes? If yes, investigate before proceeding.
- [ ] Check if branch is up-to-date: `git fetch origin`

---

## During Session (As Work Happens)

- [ ] Take brief notes as work progresses (can paste into PROGRESS.md later)
- [ ] Agent returns JSON summary — capture findings
- [ ] Reviewer results — note PASS/CHANGES_REQUESTED/BLOCKER verdict
- [ ] If revisions needed — log the issue + fix applied

**Example notes:**
```
- Agent: spec-author completed receipt-pipeline.md
- Reviewer: found 3 MAJOR issues (Claude API response wrapping, reconciliation logic, confidence_score)
- Revision round: agent fixed all 3 issues
- Final check: PASS
```

---

## Post-Session Checklist

### 1. Read Current State
```bash
git status
# Should show: "On branch feature/... nothing to commit, working tree clean"
# If not clean: investigate uncommitted files
```

### 2. Update work-list.json
- [ ] Mark completed items as `passing` (with evidence from work done)
- [ ] Mark blocked items with reason + blocker description
- [ ] Mark partial items with what's left to do
- [ ] Add `last_updated` timestamp (today's date in YYYY-MM-DD format)

**Example entry:**
```json
{
  "id": "spec-001",
  "status": "passing",
  "evidence": ["Stack choice rationale: React 18 + Fastify + PostgreSQL + MinIO + Claude API + Docker", "Architecture diagram provided", "All 9 constraints satisfied"],
  "notes": "Ready for Phase 3"
}
```

### 3. Log to PROGRESS.md
- [ ] Append one entry per session (use template below)
- [ ] Include: what was done, where it stopped, exit criteria met, evidence, blockers, next steps
- [ ] Reference affected work-list items and files

**Template:**
```markdown
### YYYY-MM-DD HH:MM — Claude Code (PM) — [Phase summary]
- **Phase/folder:** [e.g., 02-spec]
- **Status:** done | partial | blocked | failed
- **What was done:** [concise summary]
- **Where it stopped:** [last completed step / file]
- **Evidence / how verified:** [exit criteria met, tests run, reviewers PASS, etc.]
- **Broken or unverified:** [half-done paths; "none" if clean]
- **Issue (if any):** [error, blocker, decision needed; "none" if clean]
- **Next step:** [what should happen next]
- **Refs:** [files touched, work-list items, ADR ids]
```

**Real example (from Phase 2):**
```markdown
### 2026-06-09 18:00 — Claude Code (PM) — Phase 2 APPROVED: all specs passing, ready for Phase 3
- **Phase/folder:** 02-spec
- **Status:** done (approved at human gate)
- **What was done:** Completed Phase 2 final gate: comprehensive review (2 rounds), revision loop (11 MAJOR fixes + 1 regression fix), cross-file consistency verification. All 4 spec items marked PASS.
- **Where it stopped:** Phase 2 exit criteria fully met. All specs implementation-ready. Ready for Phase 3 kickoff.
- **Evidence / how verified:** (1) spec-001 (stack.md): React 18 + Fastify + PostgreSQL + MinIO + Claude API + Docker; all 9 constraints satisfied. (2) spec-002 (data-model.md): 15 entities with RBAC, audit logging, offline sync. (3) spec-003 (receipt-pipeline.md): 4-phase pipeline with error matrix. (4) spec-004 (tech-spec.md + coding-standards.md): 25+ endpoints, TypeScript strict mode, testing strategy. (5) Reviewer round 1: 18 findings (11 MAJOR, 7 MINOR). (6) Spec-author revision: all 11 MAJOR issues fixed in one batch. (7) Reviewer round 2: all fixes verified; 1 regression found (Claude model name). (8) PM fix: model name aligned. (9) Final check: PASS.
- **Broken or unverified:** None. All exit criteria met. No open findings. No TODOs/placeholders.
- **Issue (if any):** None. Process identified concurrent edit inefficiency; documented solution in protocol.
- **Next step:** (1) Merge feature branch to main (GitHub PR #5, Gate 3). (2) Begin Phase 3 (03-build) — build-author uses these specs for implementation.
- **Refs:** PR #5, feature/02-spec-complete-all-deliverables (5 commits), `.claude/docs/orchestration-protocol.md` (synchronization), `work-list.json` (spec-001 through spec-004 all PASS)
```

### 4. Stage & Commit Tracking Files
```bash
git add work-list.json PROGRESS.md
git commit -m "Log [phase] completion to tracking files

- Mark [X] items passing/blocked/partial
- Add PROGRESS entry: [brief what was done]
- Next: [what's next]

Co-Authored-By: Claude Haiku 4.5 <noreply@anthropic.com>"
```

**Why separate commit?** Tracking updates are distinct from deliverables (agents' work). Keeps git history clean.

### 5. Push to Remote
```bash
git push origin [current-branch]
```

**Verify:** Check GitHub that commit landed on the branch.

### 6. Summarize for User

**Print to user (one paragraph):**
```
Phase 2 complete: all 4 spec items passing (stack, data model, receipt pipeline, tech spec + coding standards). 
2 review rounds + revision loop resolved all findings. Branch: feature/02-spec-complete-all-deliverables (7 commits). 
Ready for merge + Phase 3 kickoff (build-author implements against these specs).
```

---

## If Something Goes Wrong

### Merge Conflict in Tracking Files

**If `git commit` fails with conflict in work-list.json or PROGRESS.md:**

1. **Don't force-push.** Someone else edited the file concurrently.
2. **Read the current state:**
   ```bash
   git pull origin [branch]
   # Resolve the conflict by hand
   ```
3. **Merge conflict markers?** Edit the file, keep both entries (don't delete prior work).
4. **Re-commit:**
   ```bash
   git add work-list.json PROGRESS.md
   git commit -m "Merge tracking updates (resolved conflict)"
   git push origin [branch]
   ```

### Uncommitted Changes Left Over

**If `git status` shows modified files you didn't create:**

1. **Don't delete.** Investigate first:
   ```bash
   git diff [filename]
   # See what changed and why
   ```
2. **If agent-created:** They should have committed. Ask them to commit their work.
3. **If linter/formatter:** Safe to `git checkout [filename]` to revert.

---

## Quick Reference: Step 8 of Orchestration Protocol

This checklist IS **Step 8: Close Out** from `orchestration-protocol.md`.

**In the 8-step loop:**
- Step 1-7: Produce → Review → Revise → Score → Gate
- **Step 8 (this checklist):** Close Out
  1. Log to PROGRESS.md (what was done, evidence, next steps)
  2. Update work-list.json (mark items passing/blocked)
  3. Commit tracking updates (`git commit`)
  4. Push to remote (`git push`)
  5. Summarize for user (one paragraph, what's next)

---

## Checklist: Every Session, Do This

- [ ] Read git status (clean?)
- [ ] Update work-list.json (mark items + add evidence)
- [ ] Append PROGRESS.md entry (what was done, where it stopped, next steps)
- [ ] Run: `git add work-list.json PROGRESS.md`
- [ ] Run: `git commit -m "Log [phase] completion"`
- [ ] Run: `git push origin [branch]`
- [ ] Tell user: one-paragraph summary + what's next

**Total time:** ~5 minutes per session.

---

## References

- **Orchestration Protocol:** `orchestration-protocol.md` (Step 8: Close Out references this checklist)
- **Work-list:** `../../work-list.json` (forward-looking backlog)
- **Progress Log:** `../../PROGRESS.md` (backward-looking log, append here)
- **Git Workflow:** `guardrails_git.md` (commit message format, branch naming)
