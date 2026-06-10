# Technical Specification — Template

**Purpose:** Document system architecture, API design, and implementation details.

## System Architecture

ASCII diagram showing all components and data flows.

```
[Client] → [API] → [Backend Service] → [Database]
                       ↓
                   [Queue/Cache]
```

## API Design

### Endpoint 1: [POST /resource]

**Request:**
```json
{
  "field1": "value1",
  "field2": "value2"
}
```

**Response:**
```json
{
  "id": "uuid",
  "field1": "value1",
  "created_at": "2026-06-11T..."
}
```

**Errors:**
- 400 Bad Request: [when]
- 401 Unauthorized: [when]
- 409 Conflict: [when]

### Endpoint 2: [GET /resource/:id]
[Similar structure]

## Security Model

- Authentication: [JWT? OAuth?]
- Authorization: [Role-based access control?]
- Data isolation: [By company? By user?]
- Secrets management: [Environment variables? Vault?]

## Error Handling

Common error scenarios and recovery paths.

## Performance Targets

- API response time: [target p95 latency]
- Query latency: [target for critical paths]
- Throughput: [requests/sec target]

---

**After tech spec, move to coding-standards.md to document implementation patterns.**
