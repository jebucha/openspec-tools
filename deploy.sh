#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

TARGET="${1:-.}"
TARGET="$(cd "$TARGET" && pwd)"

if [[ ! -d "$TARGET/.opencode" ]]; then
  echo "Error: $TARGET/.opencode/ not found."
  echo "Run 'openspec init' in $TARGET first, then try again."
  exit 1
fi

# Deploy all commands
mkdir -p "$TARGET/.opencode/commands"
for cmd in "$SCRIPT_DIR"/command/*.md; do
  [[ -f "$cmd" ]] || continue
  cp "$cmd" "$TARGET/.opencode/commands/"
  echo "  Installed command: $(basename "$cmd")"
done

# Deploy all skills
for skill_dir in "$SCRIPT_DIR"/skill/*/; do
  [[ -d "$skill_dir" ]] || continue
  skill_name="$(basename "$skill_dir")"
  mkdir -p "$TARGET/.opencode/skills/$skill_name"
  cp "$skill_dir"* "$TARGET/.opencode/skills/$skill_name/" 2>/dev/null || true
  echo "  Installed skill: $skill_name"
done

echo ""
echo "Deployed openspec-tools to $TARGET"
