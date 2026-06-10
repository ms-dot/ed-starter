#!/bin/bash
# Hook: sessionStart
# Triggered when a Copilot agent session begins.
# Use to initialize environment, validate prerequisites, set variables.

set -euo pipefail

echo "🚀 [sessionStart] Agent session initialized"
echo "   Timestamp: $(date -u '+%Y-%m-%dT%H:%M:%SZ')"
echo "   Working directory: $(pwd)"

# Verify Node.js and npm are available
if ! command -v node &>/dev/null; then
  echo "❌ Node.js is not installed" >&2
  exit 1
fi

# Verify dependencies are installed
if [ ! -d "node_modules" ]; then
  echo "⚠️  node_modules missing — running npm install"
  npm ci --quiet
fi

echo "✅ [sessionStart] Environment ready (Node $(node -v))"
