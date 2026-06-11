# Framework Development Workflows

This document provides step-by-step procedures for developing, testing, and evolving the acc-governance framework itself.

---

## Testing or Modifying an Agent

Use this workflow when you need to fix a broken agent, adjust its behavior, or add a new reviewer.

**1. Choose a work-list item**
- Use a real item from an active project (not a hypothetical test case)
- Ensure the item has context: phase CLAUDE.md, templates, state files

**2. Run the agent**
- Brief it with full context: work-list item + exit criteria + reference files
- Dispatch it and collect its output

**3. Review output**
- Verify JSON structure matches `.claude/agents/output-format.md`
- Check that findings are accurate and actionable
- Log verdict in PROGRESS.md

**4. Modify the agent** (if needed)
- Edit `.claude/agents/agent-name.md` — adjust scope, rules, or checks
- If scope changed, update the reviewer matrix in `.claude/agents/README.md`
- Re-run against the same work-list item to verify the fix
- Confirm no regressions with other phases

**5. Document the change**
- Create an ADR in `decisions/adr-*.md` (why this change, what it fixes)
- Append to PROGRESS.md with: agent name, what changed, why, verification results

---

## Evolving the Framework (Adding Reviewers, Phases, or Policies)

The framework evolves through its own deterministic pipeline: `.claude/governance-improvement/`.

### **The Governance-Improvement Pipeline**

**5 phases for framework improvements:**

| Phase | Agent | Owns | Output |
|-------|-------|------|--------|
| 1 | `framework-definer` | `.claude/governance-improvement/01-framework-define/` | Flaw analysis, philosophy, roadmap (RFC-style) |
| 2 | `framework-architect` | `.claude/governance-improvement/02-framework-spec/` | 7 detailed improvement specs |
| 3 | `framework-builder` | `.claude/governance-improvement/03-framework-build/` | Agent code, schemas, templates |
| 4 | `framework-validator` | `.claude/governance-improvement/04-framework-validation/` | Test results on real projects (no regressions) |
| 5 | `framework-shipper` | `.claude/governance-improvement/05-framework-ship/` | Migration guide, adoption handbook, rollout plan |

### **How to Propose a Change**

1. **File an ADR** in `decisions/adr-*.md`
   - Title: "Add [feature]" or "Fix [issue]"
   - Problem: What's broken or missing?
   - Proposed solution: How will this fix it?
   - Alternatives: Why not X, Y, Z?
   - Impact: Which projects/phases are affected?

2. **Brief framework-definer** with the ADR + change proposal
   - Let it analyze the flaw, document philosophy, propose 7 improvement ideas
   - Pick the best idea (or let it recommend)

3. **Brief framework-architect** to design the chosen improvement
   - Spec it: scope, rules, output format, integration points
   - Update `.claude/agents/README.md` matrix if needed

4. **Brief framework-builder** to implement
   - Code the agent (if new reviewer) or modify core protocols
   - Update templates, orchestration-protocol.md, Quick Links
   - Keep backwards-compatible (or file a migration plan)

5. **Brief framework-validator** to test on real projects
   - Run the framework-improvement pipeline on 2–3 active projects
   - Verify: no regressions, old projects still work, zero forced migration
   - If issues found, loop back to builder (up to 5 revision cycles)

6. **Brief framework-shipper** to create adoption materials
   - Adoption guide: when/how to enable, customization steps
   - Migration plan (if breaking changes): how to migrate active projects
   - Rollout strategy: phased? all-at-once?
   - Announce in README.md + CLAUDE.md + `.claude/docs/FRAMEWORK-EVOLUTION.md`

### **Example: Adding a Domain Reviewer**

Suppose you want to add an `ml-reviewer` for ML projects.

**Step 1: ADR**
```
# ADR: Add ML-Reviewer for Model Validation

## Problem
Spec phase doesn't validate ML-specific concerns: model architecture, training/inference pipeline, 
data versioning strategy, reproducibility. Security-architect checks design but misses ML ops.

## Solution
Add `ml-reviewer` that audits: model selection rationale, training data provenance, 
inference latency requirements, retraining triggers, drift detection.

## Impact
- Affects: Phase 2 (spec), Phase 3 (build), Phase 5 (test/ship)
- Opt-in: Yes (only if project has ML component)
- Breaking: No (adds new parallel reviewer; existing projects unaffected)
```

**Step 2: framework-definer analyzes**
- Identifies 7 improvement ideas (not just ml-reviewer; e.g., also data-reviewer, ops-reviewer)
- Recommends ml-reviewer as priority #1
- Documents ML governance philosophy

**Step 3: framework-architect designs**
- Spec: what phases, which reviewers it runs with, what it checks
- Output: JSON schema for findings (model, rationale, risks, recommendations)
- Integration: update `.claude/agents/README.md` matrix (Phase 2✓, 3✓, 5✓)

**Step 4: framework-builder implements**
- Create `.claude/agents/ml-reviewer.md` (full agent definition)
- Update `.claude/agents/README.md` matrix
- Update `orchestration-protocol.md` (add ML phase notes)
- Create sample output in `output-format.md`

**Step 5: framework-validator tests**
- Run on a real ML project (e.g., forecasting system from 01-define through 05-test-ship)
- Verify ml-reviewer produces actionable findings (not noise)
- Run on a non-ML project: confirm ml-reviewer is skipped or gracefully no-ops
- Test upgrade path: old project doesn't break

**Step 6: framework-shipper documents**
- Adoption guide: "When to enable ml-reviewer" (if model.type == 'ml' in spec)
- Customization: "Override checks per project" (e.g., skip if inference latency not critical)
- Announce in README.md: "Phase 2 now includes ML-specific validation"

---

## Customizing the Framework for Your Project

If you copy acc-governance for a new project:

**1. Update GLOSSARY.md**
- Add your domain terms (agents will add new ones during work)
- Example: Fintech project adds `settlement_window`, `counterparty_risk`, `reconciliation_tolerance`

**2. Update work-list.json**
- Define your deliverables (or let `project-init` populate it)
- Set item status: `not_started`, `in_progress`, `passing`, `blocked`
- Track owner + verification

**3. Customize phase exit criteria** (optional)
- Edit each `0X-name/CLAUDE.md` (adjust reviewers if needed)
- Example: Compliance-heavy project adds `compliance-reviewer` to phases 2–5

**4. Add domain reviewers** (optional)
- Create `.claude/agents/your-reviewer.md` (scope, rules, output format)
- Update `.claude/agents/README.md` matrix
- Example: Healthcare project adds `hipaa-reviewer` (phase 2–5)

**5. Run the 8-step loop**
- Pick one work-list item
- Follow `.claude/docs/orchestration-protocol.md`
- Let PM (Claude Code) orchestrate: brief agent → dispatch reviewers → collect findings → revise → gate

---

## Quick Reference: When to Modify vs. Evolve

| Task | Approach | Where |
|------|----------|-------|
| Fix a broken agent (output malformed, finding inaccurate) | Test/modify workflow | This doc, § Testing |
| Add a reviewer for a domain (ML, compliance, etc.) | Governance-improvement pipeline | This doc, § Evolving |
| Change phase exit criteria (which reviewers run, what's required) | Edit phase CLAUDE.md + ADR | Phase folder + decisions/ |
| Rename a reviewer or phase | Governance-improvement pipeline + ADR | Framework pipeline |
| Adjust orchestration loop (e.g., max revision cycles) | ADR + modify orchestration-protocol.md | decisions/ + .claude/docs/ |
| Update a template (prd-template.md, etc.) | Direct edit + ADR | Phase folder + decisions/ |

---

## State Management

All framework development is tracked in git:

| File | Purpose |
|------|---------|
| `decisions/adr-*.md` | Why a change was made (ADR for all non-trivial decisions) |
| `PROGRESS.md` | Audit log of framework changes and validations |
| `.claude/agents/agent-name.md` | Agent definition (scope, rules, output format) |
| `.claude/agents/README.md` | Agent registry + reviewer matrix |
| `.claude/docs/orchestration-protocol.md` | 8-step PM loop (if you modify it, ADR required) |
| `.claude/docs/rules.md` | Core constraints (if you modify, ADR required) |
| `.claude/docs/guardrails.md` | Restricted actions (if you modify, ADR required) |

---

## Troubleshooting

| Issue | Resolution |
|-------|-----------|
| Agent produces malformed JSON | Fix agent definition; re-run against same work-list item; verify output-format.md match |
| Reviewer finds too many issues (reviewer noise) | Review its scope (`.claude/agents/reviewer.md`); adjust checks; retest on same project |
| Framework change breaks old projects | Run framework-validator on old projects; ensure backwards-compatibility; update migration guide |
| Unsure if change needs ADR | File one. It's append-only and helps future-you understand why. Low cost, high value. |

---

## See Also

- `.claude/docs/orchestration-protocol.md` — The 8-step PM loop (what you're orchestrating)
- `.claude/docs/FRAMEWORK-EVOLUTION.md` — RFC process for framework proposals
- `.claude/docs/rules.md` — Core constraints (what agents can/cannot do)
- `.claude/docs/guardrails.md` — Restricted actions (no force-push, no skipping security, etc.)
- `.claude/agents/README.md` — Agent registry + reviewer matrix
