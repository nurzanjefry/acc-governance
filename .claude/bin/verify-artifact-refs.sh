#!/bin/bash
# PM Cross-Link Verification Tool
# Verifies all artifact references are bidirectional
#
# Usage: ./verify-artifact-refs.sh <artifact-path>
# Example: ./verify-artifact-refs.sh .claude/logs/phase-a-complete-audit-summary.md

set -e

ARTIFACT=$1

if [ -z "$ARTIFACT" ]; then
  echo "Usage: $0 <artifact-path>"
  echo "Example: $0 .claude/logs/phase-a-complete-audit-summary.md"
  exit 1
fi

if [ ! -f "$ARTIFACT" ]; then
  echo "Error: Artifact file not found: $ARTIFACT"
  exit 1
fi

ARTIFACT_NAME=$(basename "$ARTIFACT")
ARTIFACT_PATH=$(cd "$(dirname "$ARTIFACT")" && pwd)

echo "Verifying references for: $ARTIFACT_NAME"
echo "========================================================"
echo ""

# Extract and list references from artifact
echo "Cross-links listed in artifact:"
if grep -A 20 "## References & Cross-Links" "$ARTIFACT" | grep -q "^-"; then
  grep -A 20 "## References & Cross-Links" "$ARTIFACT" | grep "^- " | sed 's/^- /  /'
else
  echo "  (none found)"
fi

echo ""
echo "Verifying each reference exists:"
echo ""

BROKEN=0

# Check PROGRESS.md
if [ -f "PROGRESS.md" ]; then
  if grep -q "$ARTIFACT_NAME" PROGRESS.md 2>/dev/null; then
    echo "✓ PROGRESS.md references artifact"
  else
    echo "✗ PROGRESS.md does NOT reference artifact (BROKEN)"
    BROKEN=$((BROKEN + 1))
  fi
else
  echo "⚠ PROGRESS.md not found"
fi

# Check work-list.json
if [ -f "work-list.json" ]; then
  if grep -q "$ARTIFACT_NAME" work-list.json 2>/dev/null; then
    echo "✓ work-list.json references artifact"
  else
    echo "✗ work-list.json does NOT reference artifact (BROKEN)"
    BROKEN=$((BROKEN + 1))
  fi
else
  echo "⚠ work-list.json not found"
fi

# Check orchestration-protocol.md
if [ -f ".claude/docs/orchestration-protocol.md" ]; then
  if grep -q "$ARTIFACT_NAME" .claude/docs/orchestration-protocol.md 2>/dev/null; then
    echo "✓ orchestration-protocol.md references artifact"
  else
    echo "✗ orchestration-protocol.md does NOT reference artifact (BROKEN)"
    BROKEN=$((BROKEN + 1))
  fi
else
  echo "⚠ .claude/docs/orchestration-protocol.md not found"
fi

# Check for any broken ADR/file references
echo ""
echo "Checking referenced ADRs and files:"

BROKEN_REFS=0
grep -A 100 "## References & Cross-Links" "$ARTIFACT" 2>/dev/null | grep -E "(decisions/|02-spec/|\.claude/)" | head -20 | while IFS= read -r line; do
  # Extract paths like "decisions/adr-XXX-name.md" or "02-spec/file.md"
  if grep -oE '(decisions|02-spec|\.claude)/[a-z0-9\-\./_]+\.md' <<< "$line" | while read ref_path; do
    if [ -n "$ref_path" ]; then
      if [ -f "$ref_path" ]; then
        echo "  ✓ $ref_path exists"
      else
        echo "  ✗ $ref_path MISSING"
      fi
    fi
  done; then
    :
  fi
done

echo ""
echo "========================================================"

if [ $BROKEN -eq 0 ] && [ $BROKEN_REFS -eq 0 ]; then
  echo "✓ All references verified successfully."
  echo "  Safe to proceed to PM Step 8 (Handoff to Human)"
  exit 0
else
  echo "✗ Verification failed: $BROKEN broken cross-links + $BROKEN_REFS missing files"
  echo "  Fix references before proceeding to PM Step 8"
  exit 1
fi
