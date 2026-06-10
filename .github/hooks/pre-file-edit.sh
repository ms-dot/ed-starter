#!/bin/bash
# Hook: preFileEdit
# Triggered before the agent modifies or creates a file.
# Use to enforce file-level policies and protect critical files.
#
# Environment:
#   COPILOT_FILE_PATH  — path of the file about to be edited
#   COPILOT_EDIT_TYPE  — "edit" or "create"
#
# Exit 0 to allow, exit 1 to block.

set -euo pipefail

FILE_PATH="${COPILOT_FILE_PATH:-}"
EDIT_TYPE="${COPILOT_EDIT_TYPE:-edit}"

if [ -z "$FILE_PATH" ]; then
  exit 0
fi

# Block edits to lock files and CI config
PROTECTED_FILES=(
  "package-lock.json"
  "pnpm-lock.yaml"
  ".github/workflows/"
  "Dockerfile"
)

for protected in "${PROTECTED_FILES[@]}"; do
  if [[ "$FILE_PATH" == *"$protected"* ]]; then
    echo "🚫 [preFileEdit] Blocked $EDIT_TYPE of protected file: $FILE_PATH" >&2
    exit 1
  fi
done

# Warn on edits outside src/components/app directories
if [[ "$FILE_PATH" != app/* && "$FILE_PATH" != components/* && "$FILE_PATH" != store/* && "$FILE_PATH" != lib/* && "$FILE_PATH" != types/* && "$FILE_PATH" != __tests__/* ]]; then
  echo "⚠️  [preFileEdit] Editing file outside standard directories: $FILE_PATH"
fi

echo "📄 [preFileEdit] Allowing $EDIT_TYPE: $FILE_PATH"
exit 0
