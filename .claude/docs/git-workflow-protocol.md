# Git Workflow Protocol

## Branch Strategy

- Work on feature branches, never directly on `master`
- Branch naming: `feature/`, `fix/`, `docs/`, `chore/` prefixes

## PR Workflow

1. Create feature branch from `master`
2. Commit changes with clear messages
3. Push to remote
4. Open PR against `master`
5. Wait for approval and merge via GitHub (no CLI merge)

## Protected Rules

`master` branch enforces:
- All changes require PR
- 1 approval required before merge
- Force-push blocked
- Cannot delete `master` branch

## Commit Messages

Format: `type: description`

Types: `feat`, `fix`, `docs`, `chore`, `refactor`, `test`

Example: `docs: add startup checklist to CLAUDE.md`
