#!/bin/bash
# Hook: postFileEdit
# Triggered after the agent modifies or creates a file.
# Use to auto-format, validate syntax, or log changes.
#
# Environment:
#   COPILOT_FILE_PATH  — path of the file that was edited
#   COPILOT_EDIT_TYPE  — "edit" or "create"

set -euo pipefail

FILE_PATH="${COPILOT_FILE_PATH:-}"
EDIT_TYPE="${COPILOT_EDIT_TYPE:-edit}"

if [ -z "$FILE_PATH" ]; then
  exit 0
fi

echo "📝 [postFileEdit] File ${EDIT_TYPE}ed: $FILE_PATH"

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
    echo "   ⚠️  Invalid JSON syntax in $FILE_PATH" >&2
  fi
fi

# Validate TypeScript syntax
if [[ "$FILE_PATH" == *.ts || "$FILE_PATH" == *.tsx ]]; then
  if command -v npx &>/dev/null; then
    echo "   → Checking TypeScript syntax..."
    npx tsc --noEmit --pretty "$FILE_PATH" 2>/dev/null || echo "   ⚠️  TypeScript errors in $FILE_PATH"
  fi
fi

exit 0
