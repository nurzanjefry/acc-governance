# Guardrails: External Services & Data Egress

## No data egress without approval

**Don't send repo content to external services** without explicit human approval.

Examples of data egress (forbidden):
- Uploading code to a pastebin, gist, or code-sharing site
- Sending architecture diagrams to an external diagram renderer
- POSTing order data to an analytics service
- Calling a third-party API with receipt images

**Why:** External services may cache, index, or log the data. Once it's sent, you lose control. Even if you delete it later, it may be archived or indexed by search engines.

---

## Approved external services (v1)

The tech stack uses these external services with human awareness:

| Service | Purpose | Data sent | Approved |
|---|---|---|---|
| **Claude API** | Receipt image reading | Receipt images (binary) | Yes (for MVP) |
| **GitHub** | Source control | Code, docs, commit history | Yes |

**All other external APIs require approval first.**

---

## When you need an external API

If you want to integrate something new (e.g., Stripe for payments, Sentry for logging, Auth0 for auth):

1. **Identify what data would be sent** (user emails? order amounts? receipt images?)
2. **Check if there's a DPA** (Data Processing Agreement) or privacy policy
3. **Ask the human** with:
   - Service name and purpose
   - Exact data that would be sent
   - Why it's needed for this phase
   - Cost/alternatives
4. **Wait for approval** before adding the API call

Example:
> "I want to add Sentry for error logging. We'd send: error message, stack trace, server version, user_id, company_id (no receipt images, no order totals). Cost: $20/mo starter plan. Alternatives: self-hosted error logger (more work), just log to files (less visibility)."

---

## Network calls in code

When writing code that calls external services:

- **Document the call:** why, what data, who approved
- **Add error handling:** if the service is down, app continues (graceful degradation)
- **Log the call:** structure logs so you can audit what was sent
- **Rate-limit:** don't spam the external service (e.g., Claude API: batch requests, implement backoff)

Example (Claude API receipt reading):
```typescript
// Approved: Claude API for receipt image reading (data: image blob only)
const response = await claudeClient.vision({
  image: receiptBlob,
  prompt: "Extract receipt data..."
});
```

---

## No credential leaks to external services

Don't:
- Accidentally send API keys to external services (they'll be stolen)
- Log credentials in error messages sent to external loggers
- Send full SQL query strings to monitoring services (they may contain secrets)

Always redact:
```typescript
// ❌ Bad: logs contain the key
logger.error(`Claude API failed: ${claudeApiKey}`);

// ✓ Good: logs redact the key
logger.error(`Claude API failed: key=sk-****`);
```

---

## DNS/network policy

Projects built on this framework may use **self-hosted or cloud deployment** strategies. When designing guardrails:

- Minimize mandatory calls to external services (optional where possible)
- No tracking/telemetry without explicit user consent
- Avoid vendor lock-in where feasible
- If a feature requires an external service, consider making it optional

Examples:
- Feature works without it (degraded mode)
- Or users deploy the service themselves (e.g., analytics processor)

---

## Third-party dependencies

When adding npm/pip/gem dependencies:

- Check if it calls external APIs (many npm packages do)
- Read the privacy policy/source code
- Ask the human if you're unsure
- Document the dependency and why it's needed

Example: before adding a package that calls a CDN for fonts, verify it's OK to do so.

---

## Development vs. production

- **Development:** You can test with external services (staging API keys, test accounts)
- **Production:** Only approved, documented services with DPAs (if applicable)

Always use separate credentials for dev/prod (never reuse prod keys in local testing).
