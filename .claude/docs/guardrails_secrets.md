# Guardrails: Secrets & Credentials

## Never commit secrets

Files that must never be committed:
- `.env`, `.env.local`, `.env.*.local` (all environment files with real values)
- `credentials.json`, `service-account-key.json`, `aws-keys.json`
- Private keys, certificates, PEM files
- Any file containing API keys, tokens, passwords, or connection strings
- Real receipt images (test data only; uploaded files are in `.gitignore`)

**Template files are OK:** `.env.example` (with placeholder values like `DATABASE_URL=postgres://user:CHANGE_ME@localhost/db`) is safe to commit.

---

## Pre-commit hook enforcement

The repo has a system-level pre-commit hook (`.githooks/pre-commit`) that scans staged content for credential patterns:
- AWS keys (`AKIA...`)
- GCP service account JSON
- OpenAI/Anthropic/GitHub/Slack API keys
- Private key PEM blocks

If the hook detects a secret, it **blocks the commit** and prints `BLOCK: credentials detected`. You must remove the file and re-stage.

**Bypass:** `git commit --no-verify` skips the hook (only do this if you're certain the file is safe and need human review first).

---

## Credential rotation

If a secret is **ever** committed (even for a moment, even in history), it must be **rotated** immediately, not just deleted:

1. Delete the secret from the repo
2. Force-push to remove it from history (with human approval + acknowledgment of the risk)
3. Rotate the actual credential: change the API key, reset the password, etc.
4. A deleted but unrotated credential is still compromised (attackers can mine git history)

---

## Environment variables in local development

Use `.env.local` (gitignored) for local development:
```
DATABASE_URL=postgres://localhost/tallybite_dev
CLAUDE_API_KEY=sk-...
MINIO_ROOT_PASSWORD=minioadmin
```

Use `.env.example` (committed) as a template for what variables are needed:
```
DATABASE_URL=postgres://user:password@host/db
CLAUDE_API_KEY=sk-...
MINIO_ROOT_PASSWORD=...
```

---

## `.gitignore` coverage

The repo `.gitignore` currently covers:
- `.env*` and `secrets/`
- `uploads/`, `receipts/` (user-uploaded files with potential PII)
- `node_modules/`, build outputs
- OS/editor temp files
- `.claude/settings.local.json` (user-specific settings)

Before committing any new directory with secrets or uploads, add it to `.gitignore` and verify with `git check-ignore -v <filename>`.
