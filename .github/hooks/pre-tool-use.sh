#!/bin/bash
# Hook: preToolUse
# Triggered before the agent executes any tool call.
# Receives tool name and arguments via environment variables.
#
# Environment:
#   COPILOT_TOOL_NAME  — name of the tool about to run
#   COPILOT_TOOL_ARGS  — JSON string of tool arguments
#
# Exit 0 to allow, exit 1 to block the tool call.

set -euo pipefail

TOOL_NAME="${COPILOT_TOOL_NAME:-unknown}"

# Block destructive commands in production branches
CURRENT_BRANCH=$(git rev-parse --abbrev-ref HEAD 2>/dev/null || echo "unknown")
PROTECTED_BRANCHES=("main" "production" "release")

if [[ "$TOOL_NAME" == "bash" ]]; then
  for branch in "${PROTECTED_BRANCHES[@]}"; do
    if [[ "$CURRENT_BRANCH" == "$branch" ]]; then
      ARGS="${COPILOT_TOOL_ARGS:-}"
      if echo "$ARGS" | grep -qE '(rm -rf|DROP TABLE|git push --force)'; then
        echo "🚫 [preToolUse] Blocked destructive command on protected branch '$branch'" >&2
        exit 1
      fi
    fi
  done
fi

echo "🔧 [preToolUse] Allowing tool: $TOOL_NAME"
exit 0
