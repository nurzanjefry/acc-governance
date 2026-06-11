# Git Workflow Protocol

## Branch Naming Convention

| Type | Pattern | Example | When |
|------|---------|---------|------|
| Feature | `feature/<phase>-<item>` | `feature/02-spec-data-model` | New phase deliverable |
| Fix | `fix/<phase>-<cycle>` | `fix/02-spec-phase-a.2` | Validator findings revision |
| Docs | `docs/<topic>` | `docs/git-workflow-protocol` | Doc improvements |
| Chore | `chore/<what>` | `chore/update-config` | Infrastructure changes |

**Rules:**
- Lowercase, hyphens only (no underscores)
- Branch off `master`, never off another branch
- Delete branch after PR merged
- One branch per phase item or revision cycle

## Commit Message Format (Conventional Commits)

```
<type>(<scope>): <subject>

<body>

Co-Authored-By: Claude <Agent> <noreply@anthropic.com>
```

**Type:** `feat` | `fix` | `docs` | `refactor` | `test` | `chore`

**Scope:** phase + item (e.g., `02-spec-data-model`)

**Subject:** 50 chars max, imperative mood, no period

**Body:** Explain WHY (not WHAT). Reference validator findings if fix.

**Example:**
```
feat(02-spec): add startup checklist to CLAUDE.md

Enables protocol detection across framework + project modes.
Reduces startup ambiguity for new sessions.

Co-Authored-By: Claude Code <noreply@anthropic.com>
```

**Rules:**
- Every commit requires Co-Authored-By
- Don't amend published commits (create new instead)
- Never skip hooks (`--no-verify`)

## Commit Timing (Producer Agent)

Commit after each major work unit:
- Phase A: Per category (ADRs, terminology, data model)
- Phase A.2: Per issue type
- Each commit must pass pre-commit hooks (security scan)

## When to Push (PM Decision)

Push only after:
- [ ] All validators PASS
- [ ] PM wrap-up complete
- [ ] Human approval obtained

```bash
git push origin <branch-name>
```

**Rules:**
- Never force-push
- Never push directly to master (always via PR)
- PR must pass security-reviewer before merge

## PR Creation (git-author Agent)

Create PR after PM approves. Include:
- Summary of deliverables
- Validation results (all reviewers PASS?)
- Test plan checklist
- Link to artifact if applicable

**Rules:**
- PR body must show all validator verdicts
- Requires 1 approval before merge
- Security-reviewer MUST pass
- No CLI merge (human only on GitHub)

## Protected Branch Rules

`master` enforces:
- All changes via PR
- 1 approval required
- Force-push blocked
- Cannot delete `master`

## After Merge

1. Log to PROGRESS.md: "PR #XYZ merged"
2. Delete feature branch
3. Archive artifacts
4. Wait 24-48 hours for regression check
5. Then cleanup artifacts if no issues
