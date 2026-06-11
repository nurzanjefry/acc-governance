# Git Workflow Protocol

**Part of the acc-governance PM playbook. Referenced from `orchestration-protocol.md` Steps 8–9.**

Every phase follows this git workflow. Branch naming, commit messages, and PR creation are standardized.

---

## Branch Naming Convention

| Type | Pattern | Example | When |
|------|---------|---------|------|
| Feature (new deliverable) | `feature/<phase>-<item>` | `feature/02-spec-data-model` | Start of new phase item |
| Fix (revision after validation) | `fix/<phase>-<cycle>` | `fix/02-spec-phase-a.2` | After validator findings |
| Docs (doc-only changes) | `docs/<topic>` | `docs/orchestration-protocol` | Harness/doc improvements |
| Chore (dependency, config) | `chore/<what>` | `chore/update-config-json` | Infrastructure changes |

**Rules:** Use lowercase, hyphens only. Branch off `main`, never off another branch. Delete branch after PR merged. One branch per phase item or revision cycle.

---

## Commit Message Format (Conventional Commits)

```
<type>(<scope>): <subject>

<body>

Co-Authored-By: Claude <Agent> <noreply@anthropic.com>
```

**Type:** `feat` | `fix` | `docs` | `refactor` | `test` | `chore`  
**Scope:** phase + item (e.g., `02-spec-data-model`)  
**Subject:** 50 chars max, imperative ("add", "fix", "update"), no period  
**Body:** Explain WHY (not WHAT — commit diff shows what). Reference findings if fix.

**Rules:**
- Every commit needs a Co-Authored-By (identifies which agent made it)
- Don't amend published commits — create new commit instead
- Never skip hooks (pre-commit runs security scan)

---

## When to Commit (Producer Agent)

| Stage | Commits | Example |
|-------|---------|---------|
| Phase A.1 | Per category | `feat(02-spec-adr): Add 11 ADRs` |
| Phase A.2 | Per issue | `fix(02-spec-phase-a.2): Remove needs_review boolean` |
| Phase A.3 | Per fix | `fix(02-spec-phase-a.3): Use atomic ON CONFLICT` |
| PM wrap-up | Final log | `docs(02-spec): Log Phase A wrap-up to PROGRESS.md` |

Rules: Commit to feature branch only. All commits must pass pre-commit hook.

---

## When to Push (PM Decision)

Push to remote only after:
- [ ] All validators PASS
- [ ] Artifact cross-checked (Step 6 of PM wrap-up)
- [ ] Human approval obtained

**Never force-push. Never push directly to main (always via PR).**

---

## When to Create PR (git-author Agent)

git-author creates PR at phase end, AFTER PM wrap-up complete and human approves.

**git-author responsibilities:**
1. Verify branch is clean and pushed to remote
2. Create PR with title + body (summary, validator verdicts, artifact link)
3. Wait for human to merge on GitHub — PM cannot merge

---

## PM Wrap-Up Protocol (Steps 1–12)

### Step 1: Verify All Work Complete
- [ ] All producer agents returned JSON summaries (status: complete)
- [ ] All producers committed to git (clean git status)
- [ ] All revision cycles finished
- [ ] All validators PASS
- [ ] No regressions in prior phases detected

### Step 2: Cross-Check Findings vs. Artifacts
For each revision cycle: read the artifact, read each validator verdict, confirm all blockers/majors are now PASS. If new blockers found: run another revision cycle or escalate.

### Step 3: Update work-list.json
For each work-list item: set `status: "passing"`, log `evidence`, log `verified_by` (reviewer list), log `artifact` path.

### Step 4: Update PROGRESS.md Final Entry
```markdown
### YYYY-MM-DD WRAP-UP — Phase X Complete
- Phase/folder: <phase>
- Status: complete
- Summary: [1-2 sentences]
- Metrics: N ADRs, M fixes, K/K validators PASS
- Artifacts kept: .claude/logs/... (until Phase N+1 confirms no regressions)
- Next phase: <next>
```

### Step 5: Create Phase-End Summary (For Human)
Prepare handoff: phase goal, what was delivered, finding counts, reviewer verdicts, risks, what's next. Can be in PROGRESS.md or a separate `.claude/logs/phase-<name>-handoff.md`.

### Step 6: Verify Artifact References (Completeness Gate)
Artifact must have a "References & Cross-Links" section. PROGRESS.md entry must reference the artifact. work-list.json items must have `artifact`, `cleanup_date`, `verified_by` fields. Spot-check 3 references bidirectionally. If any broken → fix, don't proceed.

### Step 7: Archive Artifacts (Don't Clean Yet)
Keep `.claude/logs/phase-<name>-*.md` until next phase's validators confirm no regressions (typically 24–48 hours).

### Step 8: Handoff to Human (Approval Gate)
Present: phase status, deliverables, findings summary, all validator verdicts, reference completeness verified, ready for next phase? **Wait for human approval before creating PR or cleaning up.**

### Step 9: Git Workflow (After Human Approval)
Invoke git-author with: branch name, PR title, PR body (summary + validator verdicts + artifact link), approval timestamp. git-author creates PR and returns URL. PM logs "PR #XYZ created" to PROGRESS.md.

### Step 10: Merge & Archive (When PR Merged)
Log "PR #XYZ merged to main" to PROGRESS.md. Delete feature branch. Keep artifacts with References section intact.

### Step 11: PM Cleanup (After Phase N+1 Validates)
After next phase's validators confirm no regressions: verify cross-checks, then delete `.claude/logs/phase-[N]-*.md`. Log cleanup to PROGRESS.md.

### Step 12: Move to Next Phase
Create artifacts for next phase, brief next producer, log in PROGRESS.md.

---

## Git Workflow in Context

| Step | Who | When |
|------|-----|------|
| Commit fixes to feature branch | Producer | After each work unit |
| Push branch, create PR | git-author | After human approval (Step 9) |
| Log + archive artifacts | PM | After PR merged |
| Delete artifacts | PM | After Phase N+1 validates |

---

## git-author Agent Role

**When invoked:** PM wrap-up Step 9, after human approval.

**Does:** Verify branch is pushed → create PR with title + validated body → report PR URL.

**Does NOT:** Commit, push to main, merge, force-push, or rebase.
