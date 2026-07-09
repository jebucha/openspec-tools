#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

# Parse arguments
TARGET=""
FORCE_ENV=""

for arg in "$@"; do
  case "$arg" in
    --kiro)   FORCE_ENV="kiro" ;;
    --opencode) FORCE_ENV="opencode" ;;
    *)        TARGET="$arg" ;;
  esac
done

TARGET="${TARGET:-.}"
TARGET="$(cd "$TARGET" && pwd)"

# Determine target environment
if [[ -n "$FORCE_ENV" ]]; then
  ENV="$FORCE_ENV"
elif [[ -d "$TARGET/.opencode" && -d "$TARGET/.kiro" ]]; then
  ENV="both"
elif [[ -d "$TARGET/.opencode" ]]; then
  ENV="opencode"
elif [[ -d "$TARGET/.kiro" ]]; then
  ENV="kiro"
else
  echo "Error: Neither .opencode/ nor .kiro/ found in $TARGET"
  echo ""
  echo "Initialize one of:"
  echo "  openspec init     → creates .opencode/"
  echo "  kiro init         → creates .kiro/"
  echo ""
  echo "Or force a target with --kiro or --opencode"
  exit 1
fi

deploy_opencode() {
  mkdir -p "$TARGET/.opencode/commands"
  for cmd in "$SCRIPT_DIR"/command/*.md; do
    [[ -f "$cmd" ]] || continue
    cp "$cmd" "$TARGET/.opencode/commands/"
    echo "  [opencode] command: $(basename "$cmd")"
  done

  for skill_dir in "$SCRIPT_DIR"/skill/*/; do
    [[ -d "$skill_dir" ]] || continue
    skill_name="$(basename "$skill_dir")"
    mkdir -p "$TARGET/.opencode/skills/$skill_name"
    cp "$skill_dir"* "$TARGET/.opencode/skills/$skill_name/" 2>/dev/null || true
    echo "  [opencode] skill: $skill_name"
  done
}

deploy_kiro() {
  mkdir -p "$TARGET/.kiro/prompts"
  for cmd in "$SCRIPT_DIR"/command/*.md; do
    [[ -f "$cmd" ]] || continue
    # Kiro uses .prompt.md extension
    base="$(basename "$cmd" .md)"
    cp "$cmd" "$TARGET/.kiro/prompts/${base}.prompt.md"
    echo "  [kiro] prompt: ${base}.prompt.md"
  done

  for skill_dir in "$SCRIPT_DIR"/skill/*/; do
    [[ -d "$skill_dir" ]] || continue
    skill_name="$(basename "$skill_dir")"
    mkdir -p "$TARGET/.kiro/skills/$skill_name"
    cp "$skill_dir"* "$TARGET/.kiro/skills/$skill_name/" 2>/dev/null || true
    echo "  [kiro] skill: $skill_name"
  done
}

# Deploy based on detected/forced environment
case "$ENV" in
  opencode)
    deploy_opencode
    ;;
  kiro)
    deploy_kiro
    ;;
  both)
    deploy_opencode
    deploy_kiro
    ;;
esac

echo ""
echo "Deployed openspec-tools to $TARGET ($ENV)"
