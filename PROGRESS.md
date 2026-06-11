# PROGRESS.md

**Audit log for this project. Append-only — never delete entries.**

PM writes one entry per completed work-list item. Format: see `.claude/docs/log-format.md`.

---

<!-- Entries appear below this line, newest at the bottom -->

---

### 2026-06-11 — Maintain session: framework doc quality pass (Passes D–F + README overhaul)

**Mode:** Maintain (framework repo)
**Owner:** nurzanjefry

**What was done:**

*Pass D — Framework pipeline agent fixes*
- Fixed all 5 framework pipeline agents (definer/architect/builder/validator/shipper): removed instructions to read non-existent seed files, fixed `.claude/` path prefix, aligned to JSON summary / PM-sole-writer model

*Pass E — Oversized doc splits (150-line rule)*
- `orchestration-protocol.md` (760→390 lines): extracted git workflow to new `git-workflow-protocol.md`
- `FRAMEWORK-EVOLUTION.md` (384→40 lines): spec moved to `governance-improvement/02-framework-spec/fspec-007-framework-evolution.md`
- `agent-interface.md` (~490→215 lines): created `agent-fallback.md` + `agent-lifecycle.md`
- `error-recovery-runbook.md` (634→40 lines): created `error-recovery-git.md`, `error-recovery-agent.md`, `error-recovery-operations.md`
- `framework-metrics-guide.md` (374→100 lines): created `framework-metrics-schema.md`

*Pass F — Missing ADRs*
- `decisions/adr-007-git-based-locking.md` — why git is the synchronization primitive
- `decisions/adr-008-rfc-evolution-model.md` — committee + evidence-based RFC process for framework evolution

*Infrastructure*
- Branch protection applied to `master`: require PR, 1 approval, no force-push, no deletion
- `CLAUDE.md`: added Git & Branch Rules section
- `framework.json`: bumped version 1.0 → 1.1

*README overhaul*
- Plain-language intro and How It Works rewrite
- Added "What You Get" features table (11 features)
- Added model recommendation (Haiku is sufficient)
- Fixed 6 accuracy issues + all 11 docquality-reviewer findings
- Created `PROGRESS.md` stub

**PRs merged this session:** #5, #6
**PR open:** #7 (docs/readme-improvements → master)

**Framework version after this session:** 1.1

---

### 2026-06-11 — Framework enhancement: cross-session memory system

**Mode:** Maintain (framework repo)
**Owner:** nurzanjefry
**Branch:** feature/memory-system

**What was done:**

*Memory structure created*
- `.claude/memory/README.md` — memory system guide (extraction criteria, ownership, file format)
- `.claude/memory/project/rejection-log.md` — why items were reopened
- `.claude/memory/project/domain-insights.md` — domain patterns discovered
- `.claude/memory/agents/reviewer-calibration.md` — common reviewer findings
- `.claude/memory/agents/producer-briefs.md` — effective briefing patterns
- `.claude/memory/decisions/judgment-overrides.md` — human approvals despite concerns

*Orchestration protocol integration*
- Step 1 (Orient): PM reads memory files for cross-session context
- Step 4 (Dispatch): PM injects memory snippets into agent briefs
- Step 8 (Close-Out): PM extracts insights (>2 occurrences threshold)

*Documentation updates*
- `CLAUDE.md`: Added memory/ to State Files table + Quick Links
- `.claude/docs/ROLES.md`: Added memory extraction to PM responsibilities + state management table
- `.claude/agents/README.md`: Added memory system to quick links

**Why:** Research shows 47.3% knowledge duplication without persistent memory. Memory captures institutional knowledge (rejection reasons, reviewer patterns, judgment calls) that currently lives in gitignored logs or gets lost between sessions.

**Backward compatible:** Framework works without memory (opt-in enhancement).

**Next step:** Complete docquality fixes, push branch, create PR

**References:** 
- Research: [State of AI Agent Memory 2026](https://mem0.ai/blog/state-of-ai-agent-memory-2026)
- Plan: `.claude/plans/peaceful-snuggling-river.md`
