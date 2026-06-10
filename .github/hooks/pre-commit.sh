#!/bin/bash
# Hook: preCommit
# Triggered before the agent creates a git commit.
# Use to run linters, type checks, and tests as a gate.
#
# Exit 0 to allow commit, exit 1 to block it.

set -euo pipefail

echo "📝 [preCommit] Running pre-commit checks..."

ERRORS=0

# 1. TypeScript type check
if [ -f "tsconfig.json" ] && command -v npx &>/dev/null; then
  echo "   → TypeScript..."
  if ! npx tsc --noEmit --pretty 2>/dev/null; then
    echo "   ❌ TypeScript errors found" >&2
    ERRORS=$((ERRORS + 1))
  fi
fi

# 2. ESLint
if [ -f "eslint.config.mjs" ] && command -v npx &>/dev/null; then
  echo "   → ESLint..."
  if ! npx eslint --quiet --no-error-on-unmatched-pattern . 2>/dev/null; then
    echo "   ❌ Lint errors found" >&2
    ERRORS=$((ERRORS + 1))
  fi
fi

# 3. Tests
if grep -q '"test"' package.json 2>/dev/null; then
  echo "   → Tests..."
  if ! npx vitest run --reporter=dot 2>/dev/null; then
    echo "   ❌ Tests failed" >&2
    ERRORS=$((ERRORS + 1))
  fi
fi

# 4. No secrets in staged files
STAGED=$(git diff --cached --name-only 2>/dev/null)
if echo "$STAGED" | xargs grep -lE '(PRIVATE_KEY|SECRET_KEY|password\s*=\s*["\x27].+)' 2>/dev/null; then
  echo "   ❌ Possible secrets detected in staged files" >&2
  ERRORS=$((ERRORS + 1))
fi

if [ "$ERRORS" -gt 0 ]; then
  echo "🚫 [preCommit] Blocked — $ERRORS check(s) failed" >&2
  exit 1
fi

echo "✅ [preCommit] All checks passed"
exit 0
