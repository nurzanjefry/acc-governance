# GLOSSARY — Define Your Domain Terms

**Purpose:** Single source of truth for terminology. Every team member uses the same words for the same concepts.

---

## Instructions

For each domain term used in your project:
1. Write a one-line definition (human-readable, not jargon)
2. List what it's NOT (prevents confusion with similar terms)
3. Link to related ADRs or specs where it's used

**Example:**

```
### Order
A customer's purchase request. Contains items, quantities, and pricing.

**Not:** Shopping cart (cart is temporary; order is persisted)
**References:** product-definition.md, data-model.md, tech-spec.md
**First used:** Phase 1 (product definition)
```

---

## Your Terms

Add your domain terminology below. Keep it alphabetical for easy searching.

### [Term 1]
Definition here.

**Not:** [What it's not]  
**References:** [Where it's used]

### [Term 2]
Definition here.

**Not:** [What it's not]  
**References:** [Where it's used]

---

## When to Add Terms

- When a new concept appears in phase 1 (product definition) or phase 2 (specs)
- Before updating any spec or design doc
- When reviewers flag terminology inconsistency
- Before making any ADR or architectural decision

**Rule:** Term must be in GLOSSARY.md *before* it appears in any document.

---

## Maintaining This List

- Update when terminology changes (add "formerly called X" note)
- Remove only when explicitly decided (mark as "deprecated" instead of deletion)
- Link related terms together (e.g., "See also: [OtherTerm]")
