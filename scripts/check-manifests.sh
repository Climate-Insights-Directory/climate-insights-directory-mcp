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

CLAUDE_PLUGIN="plugins/climate-insights-directory/.claude-plugin/plugin.json"
if [ ! -f "$CLAUDE_PLUGIN" ]; then
  echo "Error: $CLAUDE_PLUGIN not found" >&2
  exit 1
fi

GEMINI_VER=$(jq -r '.version' "$GEMINI_EXT")
CLAUDE_VER=$(jq -r '.version' "$CLAUDE_PLUGIN")
if [ "$GEMINI_VER" != "$CLAUDE_VER" ]; then
  echo "Error: version mismatch: $GEMINI_EXT is $GEMINI_VER, $CLAUDE_PLUGIN is $CLAUDE_VER" >&2
  exit 1
fi

MARKETPLACE=".claude-plugin/marketplace.json"
if [ ! -f "$MARKETPLACE" ]; then
  echo "Error: $MARKETPLACE not found" >&2
  exit 1
fi

# One description, published in four places: plugin.json, gemini-extension.json and
# marketplace.json (top level and plugin entry). The Claude directory listing is a form, so it is
# copied by hand from plugin.json.
DESCRIPTION=$(jq -r '.description' "$CLAUDE_PLUGIN")
if [ -z "$DESCRIPTION" ] || [ "$DESCRIPTION" = "null" ]; then
  echo "Error: $CLAUDE_PLUGIN has no description" >&2
  exit 1
fi
for found in \
  "$(jq -r '.description' "$GEMINI_EXT")" \
  "$(jq -r '.description' "$MARKETPLACE")" \
  "$(jq -r '.plugins[0].description' "$MARKETPLACE")"; do
  if [ "$found" != "$DESCRIPTION" ]; then
    echo "Error: description differs from $CLAUDE_PLUGIN in $GEMINI_EXT or $MARKETPLACE" >&2
    exit 1
  fi
done

CLAUDE_SKILL="plugins/climate-insights-directory/skills/climate-energy-research/SKILL.md"
GEMINI_SKILL="skills/climate-energy-research/SKILL.md"

if [ ! -f "$CLAUDE_SKILL" ]; then
  echo "Error: $CLAUDE_SKILL not found" >&2
  exit 1
fi

if [ ! -f "$GEMINI_SKILL" ]; then
  echo "Error: $GEMINI_SKILL not found" >&2
  exit 1
fi

if ! cmp -s "$CLAUDE_SKILL" "$GEMINI_SKILL"; then
  echo "Error: $GEMINI_SKILL differs from $CLAUDE_SKILL; copy it again" >&2
  exit 1
fi

# GEMINI.md is always in the model's context and the skill is loaded on demand, so each rule id
# marked `<!-- rule:ID -->` in the skill must also appear in GEMINI.md.
rule_ids_of() {
  sed -n 's/.*<!-- rule:\([a-z-]*\) -->.*/\1/p' "$1" | sort -u
}

SKILL_RULES=$(rule_ids_of "$CLAUDE_SKILL")
if [ -z "$SKILL_RULES" ]; then
  echo "Error: $CLAUDE_SKILL carries no <!-- rule:ID --> markers" >&2
  exit 1
fi

GEMINI_RULES=$(rule_ids_of "GEMINI.md")
MISSING=$(printf '%s\n' "$SKILL_RULES" | grep -vxF "$GEMINI_RULES" || true)
if [ -n "$MISSING" ]; then
  echo "Error: GEMINI.md lacks rules the skill carries: $(echo $MISSING)" >&2
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
