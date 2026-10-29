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

utm_source_of() {
  jq -r "$2" "$1" | sed -n 's/.*[?&]utm_source=\([^&#]*\).*/\1/p'
}

CLAUDE_SRC=$(utm_source_of "$CLAUDE_MCP" '.mcpServers["climate-insights-directory"].url')
if [ "$CLAUDE_SRC" != "claude-code-plugin" ]; then
  echo "Error: $CLAUDE_MCP must carry utm_source=claude-code-plugin exactly (found: '$CLAUDE_SRC')" >&2
  exit 1
fi

GEMINI_SRC=$(utm_source_of "$GEMINI_EXT" '.mcpServers["climate-insights-directory"].httpUrl')
if [ "$GEMINI_SRC" != "gemini-extension" ]; then
  echo "Error: $GEMINI_EXT must carry utm_source=gemini-extension exactly (found: '$GEMINI_SRC')" >&2
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
