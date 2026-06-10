# Framework Evolution Specification (fspec-007)

**Status:** Phase 2 specification (framework-architect)  
**Date created:** 2026-06-11  
**Fixes:** Flaw #7 (No framework evolution)  
**Dependencies:** All other specs (fspec-001 through fspec-006)  
**Tier:** 4 (Intelligence)

---

## Overview

This specification defines **how the framework itself evolves** after v1.0. It includes an RFC process, governance committee charter, trigger rules, and backward-compatibility guarantees to enable safe, controlled framework improvements.

**Design Principle:** Deterministic processes (principle #3) + state-in-files documentation (principle #1) + governance by committee (human judgment).

---

## Part 1: FRAMEWORK-EVOLUTION.md (Living Document)

### Content Template

```markdown
# Framework Evolution Roadmap

**Document Owner:** Director of Engineering  
**Last Updated:** 2026-06-11  
**Version:** 1.0  

---

## Part 1: Evolution Triggers

### Trigger: Recurring Blocker Type (Add New Reviewer)

**When:** Same blocker class found 3+ times across different projects/phases

**Example:**
- Project-1 Phase 2: 4 blockers about "API versioning strategy not clear"
- Project-2 Phase 2: 3 blockers about "API versioning not backward-compatible"
- Project-3 Phase 2: 2 blockers about "API versioning inconsistent"
- Total: 9 blockers in same class across 3 projects

**Signal:** API versioning is a blind spot. Current reviewers not catching it early.

**Recommendation:** Add api-versioning-reviewer to Standard profile Phase 2

**Action:** File RFC-001-add-api-versioning-reviewer.md

---

### Trigger: Slow Phase (Extend Timeline or Split Phase)

**When:** Phase consistently takes >125% of estimated time (e.g., est. 14 days, actual 18+ days)

**Example:**
- Phase 2 (spec) consistently takes 18-20 days (est. 14 days)
- Cause: 11 reviewers running sequentially, not in parallel (discovered via metrics)

**Signal:** Phase structure may be suboptimal. Consider parallelizing or splitting.

**Recommendation:** Investigate whether Phase 2 can be split into 2 subphases (architecture-spec, detail-spec) with parallel track-ing.

**Action:** File RFC-002-phase-2-split.md

---

### Trigger: Low Convergence (Review Gating Too Loose or Spec Too Unclear)

**When:** Convergence rate < 80% (items regularly hit max revision cycles without resolving)

**Example:**
- Phase 2 convergence: 75% (6/8 items converge; 2 hit cycle 5 and escalate)
- Ratio: 12.5% of items escalate; typical ratio is 5%

**Signal:** Either specs are too unclear OR reviewers are too strict.

**Recommendation:** Tighten spec-author brief (add clarity requirements) or loosen reviewer bar (allow more minors vs. blockers).

**Action:** File RFC-003-convergence-improvement.md

---

### Trigger: High Token Budget Overrun (Reduce Reviewer Count or Tighten Cycles)

**When:** Framework tokens exceed budget by >20%

**Example:**
- Phase 2 budget: 100k tokens
- Phase 2 actual: 124k tokens (+24%)
- Cause: 3 additional revision cycles per item

**Signal:** Framework is more expensive than predicted. May indicate:
  1. Specs are poorly written (causes more cycles)
  2. Reviewer bar is too strict (causes more cycles)
  3. Estimate was optimistic

**Recommendation:** Reduce number of reviewers for Phase 2, or cap revision cycles at 3 for MVP projects.

**Action:** File RFC-004-token-budget-control.md

---

### Trigger: New Regulation or Compliance Standard

**When:** New regulation affects governance (e.g., GDPR 2.0, PCI-DSS v4.0)

**Example:**
- PCI-DSS v4.0 released; adds 20 new requirements for payment systems
- Current governance doesn't explicitly check PCI-DSS requirements

**Signal:** Enterprise profile may be insufficient. May need compliance-reviewer to review all phases.

**Recommendation:** Enhance compliance-reviewer role or add separate pci-dss-reviewer.

**Action:** File RFC-005-pci-dss-v4-compliance.md

---

## Part 2: RFC Process

### RFC Template: RFC-{NUMBER}-{TITLE}.md

```markdown
# RFC-001: Add api-versioning-reviewer to Standard Profile Phase 2

**Status:** SUBMITTED (awaiting governance committee review)  
**Date:** 2026-07-01  
**Author:** Project PM  
**Severity:** Medium (improvement, not critical)  

---

## Summary

Propose adding api-versioning-reviewer to Standard profile Phase 2 to catch API design issues early (backward compatibility, versioning strategy, endpoint consistency).

## Problem

**Example:**
- Project-1 Phase 2: 4 API versioning blockers (took 6 hours to resolve)
- Project-2 Phase 2: 3 API versioning blockers (took 4 hours to resolve)
- Project-3 Phase 2: 2 API versioning blockers (took 5 hours to resolve)
- Total: 9 blockers, 15 hours of revision cycles
- Pattern: Appears in 3/3 projects that reached Phase 2

**Root Cause:** 
- api-contract-reviewer checks API endpoint structure
- But does NOT deep-dive on versioning strategy (backward-compatibility, migration paths)
- api-versioning is a separate concern requiring specialist knowledge

## Proposed Solution

**Add api-versioning-reviewer to Standard profile, Phase 2 mandatory reviewers:**

```yaml
profiles:
  standard:
    phases:
      - id: "02-spec"
        mandatory_reviewers:
          - architecture-reviewer
          - data-model-reviewer
          - api-contract-reviewer
          - api-versioning-reviewer  # NEW
          - security-architect
          - test-strategy-reviewer
          - ... (rest of reviewers)
```

**Cost Impact:**
- Estimated tokens per review: 800 (Claude-haiku, focused task)
- Frequency: 3-4 projects/year running Phase 2 = 12 reviews/year
- Annual cost: 9,600 tokens ~= $2k/year

**Benefit:**
- Prevent 10-15 API versioning blockers/year
- Save ~20 hours of revision cycles/year
- Better API design consistency across projects
- ROI: Positive within 3 months

## Implementation Plan

**Phase 2.1 (Tiers 1-2 stable):** 
- Update governance-profiles.yaml
- Add api-versioning-reviewer to Standard profile
- Create api-versioning-reviewer agent interface

**Phase 2.2 (Tier 3 optimization):**
- Optionally add to Enterprise profile Phase 1 (define phase review)
- Create training materials for api-versioning-reviewer

**Backward Compatibility:**
- Existing projects (TallyBite) continue with 21 reviewers (no change)
- New projects (starting after RFC approval) use 22 reviewers
- No forced migration

## Decision

**Submitted:** 2026-07-01  
**Committee Review:** 2026-07-08  
**Status:** PENDING  
**Approved By:** [To be filled by governance committee]  
**Implementation Date:** [TBD]  

---
```

---

## Part 3: Governance Committee Charter

### Committee Composition

```
GOVERNANCE COMMITTEE (Framework Evolution Decision Authority)

Members:
1. Director of Engineering (chair)
2. TallyBite PM (stakeholder: using framework daily)
3. Project-A Lead (stakeholder: early adopter)
4. Architecture Reviewer (specialist: technical depth)
5. Product Lead (stakeholder: customer perspective)

Roles:
- CHAIR: Director of Engineering
  ├─ Approve/reject RFCs
  ├─ Schedule meetings
  └─ Escalate disagreements to CTO (if needed)

- STAKEHOLDERS: PM, Project Leads
  ├─ Provide use case context
  ├─ Vote on RFCs
  └─ Commit to rollout effort

- SPECIALIST: Architecture Reviewer
  ├─ Assess technical feasibility
  ├─ Identify ripple effects
  └─ Recommend alternatives

Meeting Frequency:
- Bi-weekly (every 2 weeks)
- 1 hour duration
- Agenda distributed 48 hours prior

Quorum:
- 4/5 members present required (80%)
- If chair absent, deputy is Director of Product

Decision Criteria:
- RFC must be approved by 4/5 members (80% consensus) to advance
- If 3/5 split, RFC returned to author for revision
- If 2/5 oppose, RFC requires escalation to CTO for tiebreaker
```

### Committee Responsibilities

| Responsibility | Owner | Frequency |
|---|---|---|
| Review incoming RFCs | All members | Bi-weekly |
| Assess technical feasibility | Architecture-reviewer | Bi-weekly |
| Assess stakeholder impact | PM + Project Leads | Bi-weekly |
| Approve/reject proposals | Chair (Director) | Bi-weekly |
| Monitor framework metrics | Chair | Monthly |
| Recommend evolution triggers | Chair | Monthly |
| Oversee rollout & adoption | PM | Continuous |

---

## Part 4: Evolution Rules

### When to Approve an RFC

**RFC is approved if:**

1. ✅ **Problem clearly documented** (with data: metrics, examples)
   - Not: "API versioning is hard"
   - Yes: "9 blockers across 3 projects in same class"

2. ✅ **Solution is concrete** (not vague or theoretical)
   - Not: "Improve quality somehow"
   - Yes: "Add api-versioning-reviewer to Phase 2; cost $2k/year"

3. ✅ **Backward compatibility maintained** (old projects still work)
   - Not: "Remove security-architect from Phase 1"
   - Yes: "Add api-versioning-reviewer to Phase 2 (new reviewer; no removal)"

4. ✅ **ROI is positive** (benefit > cost)
   - Cost: $2k/year in tokens
   - Benefit: 20 hours saved/year in revisions = $1.5k value minimum
   - ROI: Positive

5. ✅ **Implementation is feasible** (can be done in 1-2 weeks)
   - Not: "Redesign entire framework"
   - Yes: "Add new reviewer; update YAML configs; train agent"

### When to Reject an RFC

**RFC is rejected if:**

1. ❌ **Problem not substantiated** (no data; anecdotal only)
   - Example: "One project had API versioning issues" (only 1 data point)
   - Fix: Require 3+ occurrences before proposing

2. ❌ **Solution breaks backward compatibility** (old projects break)
   - Example: "Remove Phase 1; start with Phase 2"
   - Fix: Redesign to preserve Phase 1 option for projects that want it

3. ❌ **ROI is negative** (cost > benefit)
   - Example: Cost $50k/year; benefit is $5k/year
   - Fix: Find lower-cost solution or reconsider

4. ❌ **Implementation is risky** (affects many projects; high complexity)
   - Example: "Redesign work-list.json schema" (breaks all projects)
   - Fix: Propose phased migration approach with fallback

### When to Defer an RFC

**RFC is deferred if:**

1. ⏱️ **Blocked by other RFC** (this RFC depends on another)
   - Example: "api-versioning-reviewer RFC pending on RFC-002-phase-split"
   - Fix: Approve RFC-002 first; then approve RFC-001

2. ⏱️ **Timing not right** (framework too new; needs stabilization)
   - Example: Framework v1.0 just shipped (week 1); don't evolve yet
   - Fix: Revisit in 4 weeks once framework is stable

3. ⏱️ **Resource constraints** (team overloaded; can't implement)
   - Example: Director is focused on TallyBite Phase 5; can't review RFCs
   - Fix: Schedule review after TallyBite Phase 5 ships

---

## Part 5: Rollout Strategy

### Phase After Approval

**Once RFC approved:**

1. **Announcement** (1 day after approval)
   - Email all project teams: "RFC-001 approved; api-versioning-reviewer added"
   - Explain impact: "Only affects new projects starting after 2026-07-15"

2. **Update Config** (1 week after approval)
   - Update governance-profiles.yaml
   - Update agent registry: define api-versioning-reviewer
   - Commit to main: "feat(framework): Add api-versioning-reviewer (RFC-001 approved)"

3. **Training** (2 weeks after approval)
   - Record 30-min video: "api-versioning-reviewer role and responsibilities"
   - Create rubric: "What does api-versioning review look like?"
   - Train agent (Claude or human): "Here's api-versioning-reviewer interface"

4. **Migration Plan** (per project)
   - **TallyBite:** Continue with 21 reviewers (no change; already in Phase 5)
   - **Project-A:** If in Phase 2, can opt-in to add api-versioning-reviewer (re-review)
   - **Project-B:** When starting Phase 2, auto-include api-versioning-reviewer

5. **Rollback Plan** (if needed)
   - If api-versioning-reviewer performs poorly (finds 0 blockers), can be removed
   - Requires data: "Ineffective; zero blockers found in 10 reviews"
   - Rollback is not a hard revert; just mark as "inactive" in registry

---

## Part 6: Backward Compatibility Guarantee

### Core Guarantee

**Old framework versions continue to work. Projects can opt-in to new features.**

**Example:**

```
TallyBite started with v1.0 (21 reviewers)
API versioning RFC (RFC-001) approved; framework → v1.1 (22 reviewers)

TallyBite Phase 5 (in progress):
  ├─ Can stay on v1.0 (no change)
  ├─ Or upgrade to v1.1 (add api-versioning-reviewer if desired)
  └─ Decision: Stay on v1.0 (Phase 5 doesn't include Phase 2, so no impact)

Project-C (new project, starting 2026-08-01):
  ├─ Can choose v1.0 (old governance; 21 reviewers)
  ├─ Or choose v1.1 (new governance; 22 reviewers)
  └─ Decision: Choose v1.1 (want latest + greatest)

Migration:
  - TallyBite v1.0 → v1.1: Optional; no forced change
  - Project-C v1.0 → v1.1: Can migrate mid-project if desired
  - Cost: Re-review Phase 2 with new reviewer (1-2 days, extra $5k)
  - Risk: None (backward-compatible)
```

### Versioning Scheme

```
Framework Versions:
  v1.0 (2026-08-19 baseline)
    ├─ 5 phases
    ├─ 21 reviewers (Standard profile)
    ├─ 5 revision cycles max
    └─ governance-profiles.yaml: MVP, Standard, Enterprise
  
  v1.1 (2026-09-15 RFC-001 approved)
    ├─ 5 phases (same)
    ├─ 22 reviewers (Standard profile; added api-versioning-reviewer)
    ├─ 5 revision cycles max (same)
    └─ Backward-compatible with v1.0

  v1.2 (2026-10-30 RFC-002 approved)
    ├─ Phase 2 split into 02a (architecture) + 02b (detail spec)
    ├─ 23 reviewers
    ├─ 4 revision cycles max (improved convergence)
    └─ Migration required for projects on Phase 2
```

### Version Pinning in config.yaml

```yaml
project:
  name: tallybite
  framework_version: "v1.0"  # Pin to specific version
  auto_upgrade: false        # Don't auto-upgrade; require explicit approval
  
  # When ready to upgrade:
  # Change to: framework_version: "v1.1"
  # Then re-review affected phases
```

---

## Part 7: Implementation Checklist

**For Phase 3 (framework-builder):**

- [ ] Create FRAMEWORK-EVOLUTION.md template with evolution triggers
- [ ] Create RFC template: RFC-{NUMBER}-{TITLE}.md
- [ ] Create governance committee charter and publish to all team
- [ ] Establish meeting cadence (bi-weekly) and calendar invites
- [ ] Create metrics triggers dashboard (alert when trigger conditions met)
- [ ] Implement version pinning in config.yaml (framework_version field)
- [ ] Document rollout strategy (announcement, config updates, training, migration)
- [ ] Create RFC approval workflow (who signs off, when it becomes active)
- [ ] Test: Propose mock RFC-001-api-versioning-reviewer.md; walk through approval process
- [ ] Document: "How to propose a framework change" (user guide)
- [ ] Document: "Governance committee charter" (roles, responsibilities, meeting cadence)
- [ ] Set up RFC tracking (which RFCs are active, deferred, approved, rejected)

---

## Part 8: Example: RFC-001 (api-versioning-reviewer) Full Lifecycle

### Week 1: Trigger Detection

**Data collected (metrics from Phase 2 of 3 projects):**
- TallyBite: 4 API versioning blockers (hours to resolve: 6)
- Project-A: 3 API versioning blockers (hours to resolve: 4)
- Project-B: 2 API versioning blockers (hours to resolve: 5)
- **Pattern:** 9 blockers in same class across 3 projects = TRIGGER

**Action:** TallyBite PM files RFC-001

### Week 2: RFC Submission

```
RFC-001-api-versioning-reviewer.md submitted
Status: SUBMITTED
Awaiting: Governance committee review (scheduled for bi-weekly meeting on 2026-07-08)
```

### Week 3: Committee Review (Bi-Weekly Meeting)

**Committee members review RFC-001:**

| Member | Position | Rationale |
|---|---|---|
| Director (chair) | APPROVE | Data is strong; impact is low; ROI positive |
| TallyBite PM | APPROVE | Directly experienced API versioning pain |
| Project-A Lead | APPROVE | Had 3 blockers; want this reviewer in future |
| Architecture-Reviewer | APPROVE (conditional) | "Ensure api-versioning-reviewer doesn't duplicate api-contract-reviewer" |
| Product Lead | ABSTAIN | No opinion on internal governance |

**Decision:** APPROVED (4/5 votes; 1 abstain)  
**Condition:** Clarify how api-versioning-reviewer differs from api-contract-reviewer

### Week 4: Author Addresses Feedback

**TallyBite PM updates RFC-001:**

```markdown
## Clarification on Reviewer Role Separation

**api-contract-reviewer** (already exists):
- Focuses on: Endpoint structure, request/response format, error codes
- Checks: "Is /v1/receipts properly formatted?" "Are errors consistent?"
- Does NOT: Think about API evolution strategy, backward compatibility

**api-versioning-reviewer** (proposed):
- Focuses on: API versioning strategy, backward compatibility, migration paths
- Checks: "Can we add new fields without breaking clients?" "How do we deprecate endpoints?"
- Does NOT: Validate endpoint structure (that's api-contract-reviewer's job)

**Example Blocker Type:**
- Problem: "GET /receipts/123 returns { id, amount }. If we add { id, amount, currency }, will clients break?"
- api-contract-reviewer: "Endpoint format is valid" (passes)
- api-versioning-reviewer: "No migration strategy documented; backward-compatible API design missing" (blocker)
```

### Week 5: Approval & Implementation

**RFC-001 officially APPROVED**

**Rollout:**

1. **Update Code (Day 1-3)**
   - governance-profiles.yaml: Add api-versioning-reviewer to Standard Phase 2
   - agent registry: Create api-versioning-reviewer interface spec
   - Commit: "feat(framework): Add api-versioning-reviewer per RFC-001"

2. **Training (Day 4-7)**
   - Record video: "api-versioning-reviewer role, expectations, examples"
   - Create rubric: "API versioning design review checklist"
   - Train Claude: Load agent interface spec + rubric

3. **Announce (Day 1)**
   - Email team: "RFC-001 approved; api-versioning-reviewer added to Standard profile, effective 2026-07-15"
   - Projects affected: New projects starting Phase 2 after 2026-07-15
   - TallyBite: No change (already in Phase 5; no Phase 2 needed)

4. **Rollback Plan (if needed)**
   - If api-versioning-reviewer finds 0 blockers in 20 reviews: Consider removal
   - Process: Propose RFC-001-rollback to committee; likely approved
   - Current status: Monitor metrics; likely stable (not needed)

---

**End of Framework Evolution Specification**
