#!/bin/bash
# Hook: postCompact
# Triggered after context compaction (/compact).
# Re-injects project spec so it survives context summarization.

set -euo pipefail

echo "📋 [postCompact] Re-injecting project context..."

if [ -f ".ai/spec.md" ]; then
  echo "--- Project Specification ---"
  cat .ai/spec.md
  echo "--- End Specification ---"
else
  echo "⚠️  .ai/spec.md not found — skipping spec injection"
fi

if [ -f ".github/copilot-instructions.md" ]; then
  echo "--- Copilot Instructions ---"
  cat .github/copilot-instructions.md
  echo "--- End Instructions ---"
fi

echo "✅ [postCompact] Context re-injected"
