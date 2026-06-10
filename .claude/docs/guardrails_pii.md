# Guardrails: PII & Data Sensitivity

## Data classification

Projects built with this framework should classify data into sensitivity levels. Example structure:

| Level | Examples | Retention | Access | Masking |
|---|---|---|---|---|
| **Public** | Non-sensitive reference data | Indefinite | Any authenticated user | No |
| **Internal** | Transactional data, business metrics | Per compliance policy | Authorized roles only | No (internal) |
| **PII** | User-uploaded data, personal information, payment data | Per compliance (delete after N days) | Restricted roles only; read-only for compliance | Yes (redact sensitive fields) |

---

## Handling sensitive data

Receipt images contain:
- Store name and location (identifies the merchant)
- Order total and items (financial data)
- Timestamp (links order to time)
- Potentially: customer name, address, phone, email (if printed on receipt)

**Handling rule:**
- Store securely in MinIO with company_id-scoped access
- Never log image paths or content in plain text
- Never show raw receipt image to users except Owner/Finance (v1); restrict further in v1.1
- Deletion policy: TBD in v1.1 (compliance, audit trail vs. storage cost)

---

## What NOT to store

Don't collect or store:
- Customer credit card numbers or full PAN (only payment confirmation number)
- Passwords or session tokens (hash passwords; tokens are ephemeral)
- SSNs or government IDs
- Medical/dietary preferences (not in scope for v1)

---

## Access control for PII

By role:

| Role | Receipt images | Order totals | Customer names |
|---|---|---|---|
| **Admin** | No | No | No |
| **Owner** | Yes | Yes | Yes |
| **Cashier** | No (capture only) | No | No |
| **Finance** | Yes | Yes | Yes |
| **Manager** | Only their staff's | Yes | No |

Enforce at the database layer: queries always include `WHERE company_id = $1 AND (role = 'Owner' OR role = 'Finance')` for receipt images.

---

## Masking & anonymization (v1.1)

In future versions, consider:
- Blur customer faces/names in receipt images
- Redact full amounts (show only "amount: ***" in logs)
- Strip location data from receipts
- Archive (encrypt) old images separately

For now (v1), document the masking questions as open decisions in `decisions/adr-*.md`.

---

## Audit logging for PII access

Every access to a receipt image or order must be logged:
```
{
  "event": "receipt_viewed",
  "user_id": "cashier_123",
  "company_id": "merchant_456",
  "receipt_id": "receipt_789",
  "timestamp": "2026-06-08T18:30:00Z",
  "action": "view"
}
```

Logs are audit-trail evidence. Don't delete them (or delete with a separate compliance gate).

---

## Data retention & deletion

**v1 default:** Keep all data indefinitely (simplest).

**v1.1 decisions needed:**
- How long to keep receipt images? (30 days? 1 year? per GDPR?)
- How long to keep order records? (for accounting?)
- User request to delete their data (GDPR "right to be forgotten")?

Until v1.1 spec, assume no automatic deletion. If a user requests deletion, escalate to the human.

---

## Third-party data sharing

**Never share receipt data, order data, or user data with third parties without explicit approval.**

If asked to integrate with external services (e.g., analytics, accounting software), ask:
1. What data is being sent?
2. Does the human approve?
3. Is there a data processing agreement (DPA)?

Don't call external APIs with PII without the human's go-ahead.

---

## Local development & test data

In development/test environments:
- Use fake data: "John Doe", "$10.00", generic receipts
- Never use production data (receipts, real user info)
- If you need production data for debugging, export it with PII redacted and ask the human first

Test database fixture in `migrations/fixtures.sql`:
```sql
INSERT INTO orders (company_id, total_cents, created_at) 
VALUES (1, 1000, NOW()); -- $10.00 test order
```

Never commit real receipt images or user data.
