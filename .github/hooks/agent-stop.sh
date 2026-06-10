#!/bin/bash
# Hook: agentStop
# Triggered when the agent session is ending.
# Use to clean up temp files, generate summaries, run final checks.

set -euo pipefail

echo "🛑 [agentStop] Agent session ending"

# Clean up temp/scratch files the agent may have created
TEMP_PATTERNS=("*.tmp" "*.bak" "*.swp" ".~*")
for pattern in "${TEMP_PATTERNS[@]}"; do
  find . -maxdepth 3 -name "$pattern" -not -path "./node_modules/*" -delete 2>/dev/null || true
done

# Report uncommitted changes
CHANGED_FILES=$(git diff --name-only 2>/dev/null | wc -l | tr -d ' ')
STAGED_FILES=$(git diff --cached --name-only 2>/dev/null | wc -l | tr -d ' ')

echo "   Uncommitted changes: $CHANGED_FILES file(s)"
echo "   Staged changes: $STAGED_FILES file(s)"

if [ "$CHANGED_FILES" -gt 0 ] || [ "$STAGED_FILES" -gt 0 ]; then
  echo "   ⚠️  There are uncommitted changes — consider committing or stashing."
fi

echo "✅ [agentStop] Cleanup complete"
