# Orchestration Protocol — The PM Playbook

The PM (main Claude session) orchestrates agents through a **producer → review → fix** loop per task. This document specifies the exact steps so PM behavior is consistent across session resets.

---

## Core Principles

**State lives in files, not agents.** Workers are stateless (each Agent spawn is a clean slate); PM is also fresh each session. Both reconstruct context by reading: `work-list.json`, `PROGRESS.md`, phase docs, `GLOSSARY.md`, `CLAUDE.md`.

**Files are the handoff mechanism.** Agent output only persists if written to disk. PM briefs agents with docs to read and files to produce; agents reconstruct all context from files, write output, and return. No agent remembers anything from a prior run.

**Three tracking files:**
- `work-list.json` — forward-looking backlog (status, verification criteria, evidence)
- `PROGRESS.md` — backward-looking log (who did what, evidence, blockers, next steps); **agents may create this file if missing, following the PROGRESS.md template**
- `logs/<item-id>.md` — session log (gitignored, local only; captures agent outputs, reviewer verdicts, human approvals)

---

## Synchronization & Ownership (Conflict Prevention)

To avoid concurrent modification conflicts and retry loops, follow these ownership and synchronization rules:

### Ownership: Clear Boundaries

| Responsibility | PM | Agent |
|---|---|---|
| Write spec/code files (deliverables) | ❌ Never | ✅ Only |
| Write tracking files (work-list.json, PROGRESS.md) | ✅ Only | ❌ Never* |
| Update GLOSSARY.md (add new terms) | ✅ Only | ❌ Never |
| Commit and push deliverables | ❌ Never | ✅ Only |
| Dispatch reviewers | ✅ Only | ❌ Never |
| Brief agents on issues/revisions | ✅ Only | ❌ Never |

Agents declare what to update via `references_to_update` in their JSON summary. PM executes all writes to shared files. See ADR-005 and `.claude/docs/rules.md` — Agent concurrency model.

**Why:** Single owner per file eliminates concurrent edit conflicts. If PM needs to fix something in a deliverable, brief the agent to revise it in the next round (don't edit directly).

### Git as Synchronization Point

PM waits for **stable git state** before updating tracking files:

1. **Agent completes work** → returns JSON summary + commits to branch
2. **PM verifies** → run `git status` locally:
   ```bash
   git status
   # Should show: "On branch feature/...  nothing to commit, working tree clean"
   ```
3. **If unstaged changes exist:** agent is still working → wait (or ask)
4. **Once clean:** safe to update work-list.json + PROGRESS.md
5. **PM commits tracking** → separate "logging" commit, e.g. "Log Phase 2 completion"

**Benefit:** Git is the objective "agent finished" signal; no guessing.

### Batch Revision Pattern (Not Piecemeal)

When reviewer finds multiple issues:

**❌ Don't do this:**
```
Reviewer finds issue #1 → PM tries to fix → conflict → retry
Reviewer finds issue #2 → PM tries to fix → conflict → retry
...
```

**✅ Do this:**
```
Reviewer finds issues #1, #2, #3 (collect all)
↓
PM briefs agent: "Revise these 3 sections in one pass"
↓
Agent fixes all 3 at once, commits once
↓
PM reads once, verifies all fixed, updates tracking once
```

**Why:** One agent revision round + one commit + one PM verification = no conflict loops.

### Step 4a: Synchronization Check (Before Dispatch)

Before spawning an agent, verify git is clean:

```bash
git status
# If output shows "nothing to commit, working tree clean" → safe to proceed
# If output shows unstaged changes → previous agent still working → ask human
```

### Step 8a: Stable State (Before Tracking Update)

After agent returns JSON and before PM updates work-list.json:

```bash
git log --oneline -1
# Should show agent's recent commit (within last few minutes)

git status
# Should show "nothing to commit, working tree clean"
```

Only then:
1. Update work-list.json (status, evidence)
2. Update PROGRESS.md (log entry)
3. Commit tracking in separate commit: "Log [item-id] completion"

### Conflict Recovery (If It Happens Anyway)

If Edit tool rejects with "File has been modified since read":

1. **Don't retry immediately** — file is unstable
2. **Check git status** — is agent still working?
3. **Wait for clean state** — `git status` shows "working tree clean"
4. **Read file again** — get fresh state
5. **Edit once** — should succeed now

**Never:** Use Edit tool in a retry loop. If it fails, investigate *why* the file changed.

---

## Revision & Validation Cycle Protocol (MANDATORY)

**When a producer (spec-author, build-author, etc.) must revise work based on reviewer findings, follow this sequence exactly. Do NOT skip steps.**

### Step 0: Create Artifact (BEFORE work begins)

**Purpose:** Capture what reviewers found BEFORE producer starts revising. This is the reference point for "did we fix the right things?"

1. **Create session artifact** at `.claude/logs/<phase>-<revision>-<timestamp>.md`
   - Example: `.claude/logs/phase-a-complete-audit-summary.md`
   - Include: all reviewer findings, severity counts, list of blockers/majors/minors by reviewer

2. **Content checklist:**
   - Which reviewers found issues
   - How many blockers, majors, minors per reviewer
   - Exact locations (file:line) of each finding
   - Decision: which findings will be fixed in this revision

3. **Artifact persists until Step 5 complete.** Do NOT delete early.

### Step 1: Producer Revises (Spec-Author, Build-Author, etc.)

1. **Read the artifact** to understand exactly what was found
2. **Fix issues in order** (blockers → majors → minors)
3. **Update PROGRESS.md entry** as you work (optional checkpoint logging)
4. **Commit after each category** (recommended) or one big commit (acceptable)
5. **Return JSON summary** with files modified, fixes applied, ready for re-validation

### Step 2: Reviewers Re-Validate (Same reviewers as Step 0)

1. **Dispatch the same reviewers** who found the original issues
2. **Each reviewer spot-checks their area:**
   - Are the issues they flagged fixed?
   - Are there new regressions?
   - Are there cross-cutting inconsistencies?
3. **Result:** Each reviewer returns PASS or CHANGES REQUESTED

**Critical:** If any reviewer finds NEW blockers (not caused by your fixes, just missed in round 1), decide:
- **≤5 new blockers:** Run another revision cycle (go back to Step 1)
- **>5 new blockers:** Escalate to human (PM) for design decision

### Step 3: PM Confirms Fixes Against Artifact

1. **Read the artifact** (Step 0)
2. **Read each reviewer verdict** (Step 2)
3. **Cross-check:**
   - Did the producer fix all the blockers listed in the artifact?
   - Are all reviewers now saying PASS?
   - Are there any regressions in other areas?
4. **Decision:** Fixes are complete and validated, OR more cycles needed

**Confirmation checklist:**
- [ ] Artifact created BEFORE work (Step 0)
- [ ] Producer fixed all blockers from artifact
- [ ] All original reviewers PASS (Step 2)
- [ ] No new blockers introduced (or <5, run another cycle)
- [ ] Files in artifact match files modified by producer
- [ ] PROGRESS.md updated with comprehensive log

### Step 4: Update PROGRESS.md (PM responsibility)

**Only after all above steps are complete:**

1. **Create a PROGRESS.md entry** documenting:
   - What cycle was this? (Phase A.1, Phase A.2, etc.)
   - Which reviewers validated?
   - Blockers fixed (count + file locations)
   - Majors fixed (count + summary)
   - Minors noted (count, deferred or fixed)
   - Final verdict from each reviewer (all PASS?)
   - Artifact reference (where to find session log)
   - Next step (proceed to next phase OR run another cycle)

2. **Commit PROGRESS.md update** in a separate commit: `Log [phase-cycle]: [summary] — [counts]`

### Step 5: Cleanup (ONLY after Steps 0–4 complete)

1. **Confirm via PM review** that all reviewers PASS
2. **Artifact is no longer needed** after Phase B validation (next phase) confirms no regressions
3. **Delete artifact:** `rm .claude/logs/<phase>-<revision>-<timestamp>.md`
4. **Document in PROGRESS.md:** "Artifact cleaned up after Phase B confirmed no Phase A regressions"

**IMPORTANT:** Do NOT delete artifact until the NEXT phase's validation confirms your fixes didn't cause regressions. Keep it as reference during Phase B, Phase C, etc.

---

## Artifact Template (With References Section)

**Every phase artifact MUST include a References section for traceability and safe cleanup.**

Use this template:

```markdown
# [Phase] [Item] — Complete Audit Summary
**Date:** YYYY-MM-DD  
**Status:** All validators PASS — Ready for [Next Phase]  
**Artifact:** Session log for PM review before cleanup

---

## What [Phase] Accomplished

[Content: summarize what was done, findings fixed, etc.]

---

## References & Cross-Links

**This artifact is referenced by:**
- `PROGRESS.md` (entry: "YYYY-MM-DD COMPLETE — [Phase] [Title]")
- `work-list.json` (items: spec-001, spec-002, ...)
- `.claude/docs/orchestration-protocol.md` (§ Revision & Validation Cycle Protocol, § PM Wrap-Up Protocol)

**Related artifacts/decisions:**
- `decisions/adr-003-postgresql-database-choice.md` (created in this phase)
- `decisions/adr-004-rest-api-over-graphql.md` (created in this phase)
- ... (list all ADRs/artifacts created)

**How to verify completeness (for PM Step 6):**
1. Check that PROGRESS.md entry exists and links back to this file
2. Check that work-list.json items have `"artifact": "[path-to-this-file]"`
3. Check that work-list.json items have `"cleanup_date": "YYYY-MM-DD"` (phase+1 validation date)
4. Spot-check 3 cross-references to ensure they point back to this artifact

**How to cleanup safely (for PM Step 11):**
1. Verify Phase [N+1] validation completed (no regressions detected)
2. Verify all PROGRESS.md entries logged
3. Verify work-list.json updated with cleanup status
4. Then: `rm .claude/logs/[phase]-complete-audit-summary.md`
5. Log in PROGRESS.md: "Phase [N] artifacts cleaned up after Phase [N+1] validation"
```

**Why this matters:**
- Audit trail: "What changed and why?" → follow artifact → PROGRESS.md → ADRs
- Completeness check: Verify all docs reference all artifacts (bidirectional)
- Safe cleanup: Don't delete until verified that nothing else references it
- Regression detection: If Phase N+1 has issues, trace back via References

---

## PM Cross-Link Verification Tool (Automated)

**For large phases or multiple artifacts, use automated verification instead of manual spot-check.**

### Quick Check (Manual - Default)

```bash
# PM Step 6: Spot-check 3 references manually
grep -l "phase-a-complete-audit-summary" PROGRESS.md work-list.json .claude/docs/orchestration-protocol.md
# Should return all 3 files
```

### Full Verification (Automated - Optional)

**Example script (not yet created — forward-looking): `.claude/bin/verify-artifact-refs.sh`**

```bash
#!/bin/bash
# Verify all artifact references are bidirectional
# Usage: ./verify-artifact-refs.sh .claude/logs/phase-a-complete-audit-summary.md

ARTIFACT=$1
ARTIFACT_NAME=$(basename "$ARTIFACT")

echo "Verifying references for: $ARTIFACT_NAME"
echo "================================================"

# Extract references from artifact
echo "Cross-links listed in artifact:"
grep -A 20 "## References & Cross-Links" "$ARTIFACT" | grep "^- " | sed 's/^- /  /'

echo ""
echo "Verifying each reference exists:"

# Check PROGRESS.md
if grep -q "$ARTIFACT_NAME" PROGRESS.md; then
  echo "✓ PROGRESS.md references artifact"
else
  echo "✗ PROGRESS.md does NOT reference artifact (BROKEN)"
fi

# Check work-list.json
if grep -q "$ARTIFACT_NAME" work-list.json; then
  echo "✓ work-list.json references artifact"
else
  echo "✗ work-list.json does NOT reference artifact (BROKEN)"
fi

# Check orchestration-protocol.md
if grep -q "$ARTIFACT_NAME" .claude/docs/orchestration-protocol.md; then
  echo "✓ orchestration-protocol.md references artifact"
else
  echo "✗ orchestration-protocol.md does NOT reference artifact (BROKEN)"
fi

# Check for any broken ADR references
echo ""
echo "Checking ADRs listed in artifact:"
grep "decisions/adr-" "$ARTIFACT" | while read line; do
  adr=$(echo "$line" | grep -o "decisions/adr-[0-9]*-[a-z-]*\.md")
  if [ -f "$adr" ]; then
    echo "✓ $adr exists"
  else
    echo "✗ $adr MISSING"
  fi
done

echo ""
echo "================================================"
echo "Verification complete."
echo "If any ✗ shown, fix references before proceeding."
```

**Usage (PM Step 6):**

```bash
chmod +x .claude/bin/verify-artifact-refs.sh
./.claude/bin/verify-artifact-refs.sh .claude/logs/phase-a-complete-audit-summary.md
```

**Output example:**
```
Verifying references for: phase-a-complete-audit-summary.md
================================================
Cross-links listed in artifact:
  PROGRESS.md (entry: "2026-06-09 COMPLETE — Phase A Validation")
  work-list.json (items: spec-001, spec-002, spec-003, spec-004)
  .claude/docs/orchestration-protocol.md (§ Revision & Validation Cycle Protocol)

Verifying each reference exists:
✓ PROGRESS.md references artifact
✓ work-list.json references artifact
✓ orchestration-protocol.md references artifact

Checking ADRs listed in artifact:
✓ decisions/adr-003-postgresql-database-choice.md exists
✓ decisions/adr-004-rest-api-over-graphql.md exists
...
================================================
Verification complete.
If any ✗ shown, fix references before proceeding.
```

### Update PM Wrap-Up Step 6

**Modify Step 6 to use automated tool:**

```
### Step 6: Verify Artifact References (Completeness Gate)

**Option 1 (Quick):** Spot-check 3 references manually (see Quick Check above)

**Option 2 (Thorough):** Run automated verification script:
   ./.claude/bin/verify-artifact-refs.sh <artifact-path>

All cross-links must pass verification before proceeding to Step 8.
```

---

## Git Workflow Protocol

See `.claude/docs/git-workflow-protocol.md` for the complete protocol: branch naming, commit message format, when to push/PR, the git-author agent role, and PM wrap-up steps (Steps 1–12).

---

## The 8-Step PM Loop

Per task (one work-list item):

### Step 1: Orient

**Step 1a: Orphaned Artifact Cleanup (Safety Net)**

At the very start of every session, check for and clean up orphaned temp artifacts from prior sessions:

```bash
# Remove orphaned session logs (>2 hours old)
find .claude/logs -name "agent-*.md" -type f -mtime +0.083 -delete
# (0.083 days = 2 hours; removes logs older than 2h)

# Log cleanup result
echo "Session startup: cleaned up N orphaned artifacts"
```

If any artifacts were deleted, add to PROGRESS.md:
```
### Session Start — Cleanup
- Cleaned up N orphaned artifacts from prior session (age >2h)
```

**Read:**
- `work-list.json` (current backlog, active item, verification criteria)
- Latest `PROGRESS.md` entries (context from prior runs)
- Current phase's `CLAUDE.md` (scope, exit criteria, doc templates)

Confirm: What phase are we in? What's the active task?

### Step 2: Pick One Item

**Honor single-active-item rule:** at most one `in_progress` at a time.

- If user named a task: map it to a `work-list.json` item (or add a new one)
- Else: take the highest-priority `not_started` item
- Set it to `in_progress` **in work-list.json** (PROGRESS.md is updated later, after Step 8, when the item is complete)
- **Create `logs/<item-id>.md`** — session log (e.g., `logs/spec-001.md`) to capture work, verdicts, decisions

### Step 3: Choose the Worker

Route to the phase specialist agent:
- Phase 1 (01-define) → `define-author`
- Phase 2 (02-spec) → `spec-author`
- Phase 3 (03-build) → `build-author`
- Phase 4 (04-reconciliation) → `reconciliation-author`
- Phase 5 (05-test-ship) → `ship-author`

If no specialist fits, brief an ad-hoc worker for the task.

**When adding a new permanent role:** draft a `.claude/agents/<role>.md` definition, show the human, get approval before creating it.

### Step 4: Brief & Dispatch

Spawn the agent with:
- Item ID and work-list entry
- Verification criteria (what "done" means)
- Docs to read (phase CLAUDE.md, related context)
- Hard limits (no commits, no deletes, stay in your phase)

**Agent executes.** When done, agent returns a **JSON summary** (see `.claude/agents/output-format.md`):
```json
{
  "task_id": "spec-001",
  "phase": "02-spec",
  "status": "complete",
  "files_written": [{"path": "...", "lines": 234, "scope": "..."}],
  "exit_criteria_met": true,
  "ready_for_review": true,
  "issues": []
}
```

**PM appends to `logs/<item-id>.md`:** agent name + one-line dispatch summary.

### Step 5: Review (Reviewers Fan-Out)

Send agent output to relevant reviewers in parallel (see reviewer matrix in `.claude/agents/README.md`):

**Permanent:** `security-reviewer` always runs (never dropped, self-scopes).

**By phase:**
- Phase 1: terminology ✓, scope ✓, docquality ✓, decisions ◦, security ★
- Phase 2: terminology ✓, scope ✓, docquality ✓, decisions ◦, security ★
- Phase 3: code ✓, security ★, scope ◦
- Phase 4: scope ✓, decisions ◦, security ★
- Phase 5: scope ✓, decisions ◦, security ★

(✓ = always, ◦ = if a decision was made, ★ = permanent)

Each reviewer returns: **verdict** (PASS / CHANGES REQUESTED / BLOCK) + findings.

**PM appends to `logs/<item-id>.md`:** each reviewer verdict + key findings.

### Step 6: Revise (if needed)

If any reviewer returns `CHANGES REQUESTED` or `BLOCK`:

1. Synthesize findings (dedupe, prioritize: blockers first, then majors, then minors)
2. Brief agent on what to fix (quote reviewer findings, explain priority)
3. Re-spawn agent in **revision mode** (same task_id, "revise on reviewer feedback")
4. Agent fixes flagged sections only (don't wholesale rewrite)
5. Return JSON summary again
6. Re-run relevant reviewers (only those who flagged issues)
7. **Repeat step 5-6 up to 5 times.** If still not PASS, escalate to human with findings + agent rationale

**PM appends each revision round to `logs/<item-id>.md`.**

### Step 7: Score & Gate

Once all reviewers PASS (or 5-round cap hit + escalated):

**Fill evaluator rubric** (see `.claude/docs/evaluator-rubric.md`):
- Correctness (exit criteria met? no contradictions?)
- Verification (spot-checked files? evidence recorded?)
- Scope (serves the 9-step flow? no drift?)
- Reliability (no known blockers? clean state?)
- Maintainability (well-organized, documented, aligned to standards?)
- Handoff (clear what's next? what would break? dependencies clear?)

**Stop at human approval gate.** Show the human:
- Item summary (what was supposed to be done)
- Reviewer verdicts (all PASS? or open findings?)
- Evaluator rubric score
- Agent rationale (if revisions happened, why agent pushed back)

**Human decision:** Accept / Request changes / Reject

- **Accept:** Proceed to step 8 (close out)
- **Request changes:** Loop back to step 6 (revision), but with human's feedback outranking reviewers
- **Reject:** Mark item as `reopened` with reason; loop back to step 3 (pick new approach or new worker)

**After Owner responds, PM immediately writes a DECISION record to `logs/<item-id>.md`.**
Record the decision, Owner's rationale (verbatim or close paraphrase), and outcome.
See `.claude/docs/log-format.md` — DECISION record format. This is mandatory — no Owner decision goes unrecorded.

### Step 8: Close Out

**See `session-wrap-up.md` for the full checklist and commands.**

On **Accept:**
- Mark item `passing` in `work-list.json` (status + evidence from agent JSON)
- PM appends entry to `PROGRESS.md` using agent's `progress_entry` from JSON
- Write final AFTER record to `logs/<item-id>.md`
- Surface next candidate item from `work-list.json`

On **Request changes** → loop back to Step 6 with Owner's feedback outranking reviewers.
On **Reject** → set item `reopened` with reason, loop back to Step 3.

---

## 3-Gate Git Flow (Before Merging)

Only runs **after a task is marked `passing`** (step 8 close-out). This is separate from the PM loop; it's the path to `main`.

### Gate 1 — Content
Already done: human approved at step 7.

### Gate 2 — Staging Plan
Before any git touch:

1. Run `git status` and `git diff --stat`
2. Show human:
   - Branch name (e.g., `feature/spec-001-stack`)
   - Files to stage (list)
   - Exact commit message (subject + body)
3. Stop and wait for explicit approval ("proceed", "looks good", etc.)

### Gate 3 — Create PR (PM only)

1. Dispatch `git-author` agent with:
   - Branch name
   - File list
   - Commit message (subject + body ≤72 chars)
2. `git-author` creates branch, commits, pushes, opens PR
3. **Show human:**
   - PR number and link (e.g., #6: https://github.com/your-org/your-repo/pull/6)
   - Title
   - Files changed summary
   - **"PR created. You must merge on GitHub."**

### Gate 4 — Merge (Human only)

**PM CANNOT merge.** Only the human can merge PRs on GitHub.

**Human must:**
1. Visit PR on GitHub
2. Review the changes visually
3. Click "Merge pull request" button on GitHub (not via CLI)
4. Confirm the merge

**Why:** Merge is a destructive operation. Only the human has authority to merge code to `main`. PM can prepare (create PR), but merge is human-only gate.

---

## Revision Loop Example

Scenario: `spec-author` fills `stack.md`. Reviewers return:

- **terminology-reviewer:** PASS (all terms match GLOSSARY)
- **scope-reviewer:** CHANGES REQUESTED ("missing offline sync discussion")
- **decisions-reviewer:** PASS (no new decisions needed)
- **security-reviewer:** CHANGES REQUESTED ("self-hosted MinIO needs ACL docs")

PM action:
1. Synthesize: 2 CHANGES REQUESTED (offline, MinIO ACLs)
2. Brief spec-author: "Add offline sync rationale to Frontend section. Add MinIO ACL security notes to Storage section."
3. Re-spawn agent in revision mode
4. Agent fixes both sections
5. Return JSON summary (only two sections touched)
6. Re-run scope-reviewer + security-reviewer (only those who flagged)
7. Both return PASS
8. All reviewers PASS → proceed to step 7 (score & gate)

---

## When Things Go Wrong

**Agent error (file write fails, agent crashes):**
- Mark item `blocked`
- Document issue in PROGRESS.md
- Re-spawn with same brief, or ask human for help

**Reviewer deadlock (findings contradict):**
- Synthesize: ask human which finding takes priority
- Brief agent with human's guidance
- Resume revision loop

**Human disagrees with reviewers:**
- Human can override ("approve despite the findings")
- Document in logs and PROGRESS.md: "human approved despite X reviewer concern because Y"

**Escalation to human mid-task:**
- If agent is stuck or reviewer findings are contradictory, don't loop infinitely
- Stop at step 6/7, surface the blocker, ask human for direction
