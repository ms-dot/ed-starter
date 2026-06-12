#!/bin/bash
# Hook: postFileEdit (self-healing loop)
# Triggered after the agent modifies or creates a file.
# Auto-formats, validates syntax, and BLOCKS on errors to force agent to fix them.
#
# Environment:
#   COPILOT_FILE_PATH  — path of the file that was edited
#   COPILOT_EDIT_TYPE  — "edit" or "create"
#
# Exit 1 = block (agent must fix before continuing)
# Exit 0 = allow

set -euo pipefail

FILE_PATH="${COPILOT_FILE_PATH:-}"
EDIT_TYPE="${COPILOT_EDIT_TYPE:-edit}"

if [ -z "$FILE_PATH" ]; then
  exit 0
fi

echo "📝 [postFileEdit] File ${EDIT_TYPE}ed: $FILE_PATH"

ERRORS=0

# Auto-format with Prettier if available
if command -v npx &>/dev/null && [ -f ".prettierrc" ]; then
  case "$FILE_PATH" in
    *.ts|*.tsx|*.js|*.jsx|*.json|*.css|*.md)
      echo "   → Formatting with Prettier..."
      npx prettier --write "$FILE_PATH" 2>/dev/null || true
      ;;
  esac
fi

# Validate JSON files
if [[ "$FILE_PATH" == *.json ]]; then
  if ! python3 -m json.tool "$FILE_PATH" >/dev/null 2>&1; then
    echo "   ❌ Invalid JSON syntax in $FILE_PATH — fix before continuing" >&2
    ERRORS=$((ERRORS + 1))
  fi
fi

# Validate TypeScript syntax — block on errors
if [[ "$FILE_PATH" == *.ts || "$FILE_PATH" == *.tsx ]]; then
  if command -v npx &>/dev/null; then
    echo "   → Checking TypeScript..."
    TS_OUTPUT=$(npx tsc --noEmit --pretty 2>&1) || {
      echo "   ❌ TypeScript errors — fix before continuing:" >&2
      echo "$TS_OUTPUT" | head -30 >&2
      ERRORS=$((ERRORS + 1))
    }
  fi
fi

# Lint the edited file — block on errors
if [[ "$FILE_PATH" == *.ts || "$FILE_PATH" == *.tsx || "$FILE_PATH" == *.js || "$FILE_PATH" == *.jsx ]]; then
  if command -v npx &>/dev/null && [ -f "eslint.config.mjs" ]; then
    echo "   → Linting..."
    LINT_OUTPUT=$(npx eslint --no-error-on-unmatched-pattern "$FILE_PATH" 2>&1) || {
      echo "   ❌ ESLint errors — fix before continuing:" >&2
      echo "$LINT_OUTPUT" | head -20 >&2
      ERRORS=$((ERRORS + 1))
    }
  fi
fi

if [ "$ERRORS" -gt 0 ]; then
  echo "🚫 [postFileEdit] BLOCKED — $ERRORS check(s) failed. Fix the errors above and retry." >&2
  exit 1
fi

echo "✅ [postFileEdit] All checks passed"
exit 0
