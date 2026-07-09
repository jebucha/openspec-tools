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

mkdir -p "$TARGET/.opencode/commands"
mkdir -p "$TARGET/.opencode/skills/openspec-audit-change"

cp "$SCRIPT_DIR/command/opsx-audit.md" "$TARGET/.opencode/commands/"
cp "$SCRIPT_DIR/skill/openspec-audit-change/SKILL.md" "$TARGET/.opencode/skills/openspec-audit-change/"

echo "Installed opsx-audit to $TARGET"
