#!/bin/sh
set -e

CLAUDE_MCP="plugins/climate-insights-directory/.mcp.json"
GEMINI_EXT="gemini-extension.json"

if [ ! -f "$CLAUDE_MCP" ]; then
  echo "Error: $CLAUDE_MCP not found" >&2
  exit 1
fi

if [ ! -f "$GEMINI_EXT" ]; then
  echo "Error: $GEMINI_EXT not found" >&2
  exit 1
fi

if ! grep -q 'utm_source=claude-code-plugin' "$CLAUDE_MCP"; then
  echo "Error: $CLAUDE_MCP must carry utm_source=claude-code-plugin" >&2
  exit 1
fi

if ! grep -q 'utm_source=gemini-extension' "$GEMINI_EXT"; then
  echo "Error: $GEMINI_EXT must carry utm_source=gemini-extension" >&2
  exit 1
fi

if command -v claude >/dev/null 2>&1; then
  claude plugin validate . --strict
  claude plugin validate plugins/climate-insights-directory --strict
fi

if command -v gemini >/dev/null 2>&1; then
  gemini extensions validate .
fi

echo "Manifest checks passed."
