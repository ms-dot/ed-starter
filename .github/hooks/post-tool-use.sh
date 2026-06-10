#!/bin/bash
# Hook: postToolUse
# Triggered after the agent completes a tool call.
# Use to log results, collect metrics, or trigger side effects.
#
# Environment:
#   COPILOT_TOOL_NAME       — name of the tool that ran
#   COPILOT_TOOL_EXIT_CODE  — exit code of the tool (0 = success)
#   COPILOT_TOOL_DURATION   — execution time in milliseconds

set -euo pipefail

TOOL_NAME="${COPILOT_TOOL_NAME:-unknown}"
EXIT_CODE="${COPILOT_TOOL_EXIT_CODE:-0}"
DURATION="${COPILOT_TOOL_DURATION:-0}"

if [ "$EXIT_CODE" -ne 0 ]; then
  echo "⚠️  [postToolUse] Tool '$TOOL_NAME' failed (exit $EXIT_CODE, ${DURATION}ms)"
else
  echo "✅ [postToolUse] Tool '$TOOL_NAME' succeeded (${DURATION}ms)"
fi

# Auto-lint after file edits
if [[ "$TOOL_NAME" == "edit" || "$TOOL_NAME" == "create" ]]; then
  if command -v npx &>/dev/null && [ -f "eslint.config.mjs" ]; then
    echo "🔍 [postToolUse] Running lint check after file change..."
    npx eslint --quiet --no-error-on-unmatched-pattern . 2>/dev/null || true
  fi
fi

exit 0
