# PM Responsibilities Audit

As PM, I've reviewed the orchestration protocol and extracted all PM responsibilities. **This is a gap analysis.**

---

## ✅ What PM MUST Do (Per 8-Step Loop)

| Step | Responsibility | Done | Evidence |
|------|---|---|---|
| **1** | Clean up orphaned artifacts (age >2h) | ✅ | Lines 776-793 |
| **1** | Read work-list.json, PROGRESS.md, phase CLAUDE.md | ✅ | Lines 795-800 |
| **2** | Pick highest-priority `not_started` item (or user's choice) | ✅ | Lines 804-807 |
| **2** | Set item to `in_progress` in work-list.json | ✅ | Line 808 |
| **2** | Create session log at `logs/<item-id>.md` | ✅ | Line 809 |
| **3** | Route to correct producer agent (define/spec/build/etc.) | ✅ | Lines 813-818 |
| **4** | Brief agent with item + exit criteria + docs to read | ✅ | Lines 826-830 |
| **4** | Append to session log: agent dispatch summary | ✅ | Line 845 |
| **5** | Dispatch reviewers in parallel (use reviewer matrix) | ✅ | Lines 849-860 |
| **5** | Append to session log: each reviewer verdict + findings | ✅ | Line 864 |
| **6** | Synthesize findings (dedupe, prioritize) | ✅ | Line 870 |
| **6** | Brief agent on what to fix (batch, not piecemeal) | ✅ | Line 871 |
| **6** | Re-run relevant reviewers (only those who flagged) | ✅ | Line 875 |
| **6** | Repeat steps 5-6 up to 5 times max | ✅ | Line 876 |
| **6** | Escalate to human if >5 cycles or contradictory findings | ✅ | Line 876 |
| **7** | Fill evaluator rubric (6 dimensions) | ✅ | Lines 884-890 |
| **7** | Present to human + wait for approval (GATE) | ✅ | Lines 892-896 |
| **8** | Mark item `passing` in work-list.json (only on Accept) | ✅ | Line 910 |
| **8** | Update PROGRESS.md with final entry | ✅ | Lines 915-917 |
| **8** | Suggest next item | ✅ | Implied in Step 2 loop |

---

## ❌ What PM CANNOT Do (Hard Boundaries)

| Forbidden Action | Why | Doc Reference |
|---|---|---|
| Write/edit spec or code files directly | Causes conflicts with agent; use revision loop instead | Line 28 |
| Delete or rename deliverable files | Only agent can modify scope; ask them to revise | Line 28 |
| Commit or push agent's work | Agent commits; PM only logs tracking | Line 31 |
| Add new terms to GLOSSARY.md | Agent owns terminology; ask them to add first | Line 30 |
| Dispatch agents without approval gate | Must wait for human approval at step 7 before final commit | Line 514 |
| Merge PRs directly to main | Only human can merge; PM can only create PR | Line 514 |
| Force-push any branch | Destroys history; never acceptable | Line 478 |
| Squash commits before final review | Each commit must be reviewable; squash only after approval | Line 445 |
| Skip security-reviewer | Security is permanent gate; never drop | Line 851 |
| Skip pre-commit hooks | Hooks run security scan; non-negotiable | Line 446 |
| Delete artifacts before next phase validates | Needed for regression detection; keep 24-48h | Line 202 |
| Assume prior agent outputs are valid | Verify each agent's JSON format + contents | Output-format.md |

---

## ⚠️ PM Responsibilities GAPS (What's Missing or Unclear)

| Gap | Current State | Risk | Fix |
|---|---|---|---|
| **New project setup** | Protocol assumes work-list.json exists | PM doesn't know how to bootstrap a brand new project | Document: PM invokes project-init agent first, gets GLOSSARY.md + work-list.json populated |
| **Session startup checklist** | Step 1a only covers artifact cleanup | PM might not know full startup sequence | Add: "Read CLAUDE.md on session start → check framework version → verify git status → read PROGRESS.md for context" |
| **PM onboarding** | No "Getting Started for PM" section | New PM might not understand their role on first run | Add section before Step 1 explaining: "You orchestrate agents, you don't code" |
| **State file schemas** | References work-list.json/PROGRESS.md but no schemas | PM doesn't know exact JSON structure to write | Link to or create: work-list.json schema, PROGRESS.md template |
| **Reviewer matrix mismatch** | Step 5 shows simplified matrix (✓/◦/★) but agents/README has full matrix | PM might use wrong reviewers | Step 5 should reference `.claude/agents/README.md` directly, not duplicate |
| **Phase wrap-up location** | Described after git workflow (lines 577-768) but separate from 8-step | PM might not realize they need BOTH | Add visual: "After all items PASS step 8 → run Phase Wrap-Up (11 additional steps)" |
| **Git workflow timing** | Says "after human approval" but doesn't explicitly say BEFORE push | PM might push before human approves | Clarify: "Step 7 = human approval → Step 8 close out → THEN git workflow" |
| **Merge follow-up** | Says "wait for human to merge" but no timeout/escalation | What if human forgets for days? | Add: "If PR not merged within X hours, escalate: ask human status" |
| **Revision loop cap** | Says "max 5 cycles" but what counts as 1 cycle? | PM might waste rounds on minor changes | Clarify: "1 cycle = 1 round of revisions + 1 re-validation round (Steps 5-6)" |
| **Evidence quality** | Says "evidence: reviewer findings + verification notes" but no examples | PM might write weak evidence | Add examples: "✅ Fixed: ABC reviewer concern (lines 45-67: added X validation)" |
| **Escalation criteria** | Says ">5 new blockers = escalate" but doesn't say HOW | PM doesn't know escalation process | Add: "Escalate to human with: original findings + new findings + agent rationale + recommended action" |
| **Conflict recovery** | Says "investigate why file changed" but no decision tree | PM might not know what to do if Edit fails | Add decision tree: "Is agent still working? → wait. Is another PM session active? → ask human. Is git dirty? → run git status." |
| **Session persistence** | Says PM is fresh each session but doesn't say how to resume | PM on new session might not know they can resume mid-item | Add: "If work-list item is in_progress, PM reads logs/<item-id>.md and continues from last step" |

---

## 🔍 Contradictions Found

| Issue | Location 1 | Location 2 | Resolution |
|---|---|---|---|
| **Agent creates PROGRESS.md?** | Line 15 says agent CAN create if missing | Line 917 says PM appends entry | Clarify: Agent can create initial file; PM appends completion entries. Owner = "both (conditional)" |
| **When does PM update work-list?** | Line 808 says Step 2 (in_progress) | Line 910 says Step 8 (passing) | Clarify: Step 2 = set in_progress, Step 8 = set passing (two separate updates) |
| **Reviewer matrix scope** | Step 5 shows 5 reviewers max per phase | agents/README.md shows 14 reviewers for Phase 3 | Which is canonical? Should Step 5 reference agents/README.md directly |
| **Push responsibility** | Line 462 says "Push only after PM approves" | Line 514 says git-author creates PR | Who pushes? When? (After human approval, before git-author creates PR?) |

---

## 📋 PM Responsibilities Checklist (For Session Start)

Every session, PM should verify:

- [ ] Read CLAUDE.md (understand PM role)
- [ ] Verify orchestration-protocol.md version (no breaking changes since last session?)
- [ ] Run artifact cleanup (remove age >2h)
- [ ] Read work-list.json (what's in progress? what's next?)
- [ ] Read latest PROGRESS.md entries (where did we leave off?)
- [ ] Check git status (is repo clean? any staged files?)
- [ ] Confirm current phase (which producer agent should we brief?)
- [ ] Look for any "blocked" items (need human decision?)
- [ ] Verify security-reviewer is in reviewer matrix for this phase (never skip)

If any blocker found: ask human before proceeding to Step 2.

---

## 🚨 Critical Issues (Fix Before Using)

1. **State file schemas are missing** — PM can't write JSON without knowing structure
2. **Reviewer matrix mismatch** — Step 5 and agents/README show different matrices
3. **Phase wrap-up is separate protocol** — PM might not know to run it after all items pass
4. **New project bootstrap undefined** — Protocol assumes work-list.json exists
5. **Session persistence undefined** — PM on new session doesn't know how to resume mid-task

---

## 📊 PM Workload Summary

Per work-list item:
- **Step 1:** ~5 min (read files, orient)
- **Step 2:** ~2 min (pick item, log)
- **Step 3-4:** ~5 min (choose agent, brief)
- **Step 5:** ~10 min (dispatch 15 reviewers, wait for verdicts) [PARALLEL, not sequential]
- **Step 6:** ~20 min per cycle (synthesize, brief revisions, re-run reviewers) × up to 5 cycles
- **Step 7:** ~10 min (fill rubric, present to human, WAIT for approval)
- **Step 8:** ~10 min (update tracking, suggest next item)
- **Subtotal per item:** ~62 min + revision overhead

After all items pass:
- **Phase Wrap-Up:** ~60 min (11 additional steps: artifact verification, PR creation, handoff, cleanup, etc.)

**Total per phase:** ~N items × 62 min + 60 min wrap-up + git overhead

---

## Recommendations

**High Priority (Fix Before Using):**
1. Create work-list.json schema (JSON example + field definitions)
2. Create PROGRESS.md template (markdown example + section definitions)
3. Clarify reviewer matrix: Step 5 references agents/README.md directly (not duplicate)
4. Add "Session Startup Checklist" (7-item verification before Step 1)
5. Add "PM Onboarding" section at top of orchestration-protocol.md

**Medium Priority (Nice to Have):**
1. Add decision tree for conflict recovery (Edit tool failures)
2. Add examples of "good evidence" (what makes a quality evidence string?)
3. Clarify escalation process (when >5 new blockers, what exactly should PM do?)
4. Clarify session persistence (how to resume mid-task on new session)

**Low Priority (Polish):**
1. Add PM role section at very top ("You orchestrate, you don't code")
2. Add visual diagram: when does git workflow fit in 8-step loop?
3. Add checklist: "Can I advance to next phase?" (all items passing? all artifacts verified?)
