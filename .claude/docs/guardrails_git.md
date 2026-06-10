# Guardrails: Git & History

## No commits without approval

**You cannot commit without the human's explicit go-ahead in the current session.** Every commit must be approved by the human before it happens.

When your work is done:
1. Run `git status` and `git diff` to show what changed
2. Draft a commit message (50-char title, blank line, detailed explanation)
3. Show the human: branch name, files to commit, exact message
4. Wait for explicit approval ("proceed", "looks good", "go ahead")
5. Only then call the git tool to stage, commit, and push

**Why:** Committing is irreversible (it creates history). The human needs to confirm the content before it's permanent.

---

## No force-push, no resets, no history rewrites

Don't:
- `git push --force` or `git push --force-with-lease`
- `git reset --hard` or `git reset --soft` to earlier commits
- `git rebase -i` to reorder/squash/drop commits
- `git clean -f` to delete untracked files
- `git checkout -- <file>` to discard changes (unless you created the file)

**Why:** These commands rewrite history and can lose work. If you need to undo something:
- To undo a commit: create a new **revert commit** (`git revert HEAD`) instead of resetting
- To undo changes: stash and discard (`git stash drop`) only if you're certain
- To undo a push: contact the human for help

**Exception:** `git rebase` (non-interactive) to sync with main before pushing is OK.

---

## The 3-gate git flow

The orchestration protocol defines three approval gates before code lands:

**Gate 1 — Content:** Your work is complete and reviewed (automated reviewers PASS, human approves).

**Gate 2 — Staging plan:** PM shows you what will be committed (branch, files, message). You approve before git touch.

**Gate 3 — Merge:** Human reviews the PR on GitHub and merges. Nothing lands on `main` without a PR + review.

Between gates 2 and 3, a `git-author` subagent handles the actual `git commit` and `git push` on your behalf (you don't run git directly). On Gate 3, the human does the final merge on GitHub.

---

## Commit message format

If you're writing the commit message (rare; usually PM does this):

**Title:** Present tense, 50 characters or less.
```
Add receipt pipeline spec with offline sync
```

**Body:** Blank line, then detailed explanation (WHY, not WHAT).
```
Add receipt pipeline spec with offline sync

- 4-phase flow: capture, upload, process, AI read
- Idempotency key deduplication on upload retries
- Offline queue in IndexedDB with service worker sync
- Error matrix: 16 failure modes with recovery actions
- Performance targets: <5s upload, <45s end-to-end
```

No line in the title or body should exceed 72 characters. If the commit message is long, break it into multiple focused commits (one per logical change).

---

## Branch naming

When creating a feature branch:

`<category>/<item-id>-<slug>`

Examples:
- `feature/spec-001-stack-decisions`
- `fix/data-model-constraint`
- `docs/user-journey-offline-flow`
- `chore/add-eslint-config`

Categories: `feature`, `fix`, `docs`, `chore`, `test`.

---

## Merging strategy

- **Squash commits:** One logical change = one commit (not one per tiny save)
- **Rebase, don't merge:** Keep history linear (no "merge commit" clutter)
- **All tests pass:** CI must PASS before merge (v1.1+)
