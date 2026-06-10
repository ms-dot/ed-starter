#!/bin/bash
# Hook: postCommit
# Triggered after the agent successfully creates a git commit.
# Use to log commit metadata or trigger downstream actions.

set -euo pipefail

COMMIT_SHA=$(git rev-parse --short HEAD 2>/dev/null || echo "unknown")
COMMIT_MSG=$(git log -1 --pretty=%s 2>/dev/null || echo "unknown")
CHANGED=$(git diff-tree --no-commit-id --name-only -r HEAD 2>/dev/null | wc -l | tr -d ' ')

echo "📦 [postCommit] Commit created"
echo "   SHA: $COMMIT_SHA"
echo "   Message: $COMMIT_MSG"
echo "   Files changed: $CHANGED"

# Verify build still works after commit
if command -v npx &>/dev/null && grep -q '"build"' package.json 2>/dev/null; then
  echo "   → Verifying build..."
  if npx next build --no-lint 2>/dev/null; then
    echo "   ✅ Build OK"
  else
    echo "   ⚠️  Build failed after commit — consider reverting"
  fi
fi
