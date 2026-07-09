#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

# Parse arguments
TARGET=""
FORCE_ENV=""

for arg in "$@"; do
  case "$arg" in
    --kiro)     FORCE_ENV="kiro" ;;
    --opencode) FORCE_ENV="opencode" ;;
    --claude)   FORCE_ENV="claude" ;;
    *)          TARGET="$arg" ;;
  esac
done

TARGET="${TARGET:-.}"
TARGET="$(cd "$TARGET" && pwd)"

# Determine target environment(s)
ENVS=""
if [[ -n "$FORCE_ENV" ]]; then
  ENVS="$FORCE_ENV"
else
  [[ -d "$TARGET/.opencode" ]] && ENVS="opencode"
  [[ -d "$TARGET/.kiro" ]]     && ENVS="${ENVS:+$ENVS }kiro"
  [[ -d "$TARGET/.claude" ]]   && ENVS="${ENVS:+$ENVS }claude"
fi

if [[ -z "$ENVS" ]]; then
  echo "Error: No supported environment found in $TARGET"
  echo ""
  echo "Expected one of: .opencode/, .kiro/, .claude/"
  echo ""
  echo "Initialize one of:"
  echo "  openspec init     → creates .opencode/"
  echo "  kiro init         → creates .kiro/"
  echo "  mkdir .claude     → creates .claude/"
  echo ""
  echo "Or force a target: --opencode, --kiro, --claude"
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

deploy_claude() {
  # Claude CLI: commands use opsx-audit.md → .claude/commands/opsx/audit.md
  # The "opsx-" prefix becomes the subdirectory, remainder becomes the filename
  for cmd in "$SCRIPT_DIR"/command/*.md; do
    [[ -f "$cmd" ]] || continue
    base="$(basename "$cmd" .md)"
    # Split on first hyphen: "opsx-apply-audit" → prefix="opsx", rest="apply-audit"
    prefix="${base%%-*}"
    rest="${base#*-}"
    mkdir -p "$TARGET/.claude/commands/$prefix"
    cp "$cmd" "$TARGET/.claude/commands/$prefix/${rest}.md"
    echo "  [claude] command: $prefix/${rest}.md"
  done

  # Claude CLI: skills use same structure as opencode
  for skill_dir in "$SCRIPT_DIR"/skill/*/; do
    [[ -d "$skill_dir" ]] || continue
    skill_name="$(basename "$skill_dir")"
    mkdir -p "$TARGET/.claude/skills/$skill_name"
    cp "$skill_dir"* "$TARGET/.claude/skills/$skill_name/" 2>/dev/null || true
    echo "  [claude] skill: $skill_name"
  done
}

# Deploy to each detected/forced environment
for env in $ENVS; do
  case "$env" in
    opencode) deploy_opencode ;;
    kiro)     deploy_kiro ;;
    claude)   deploy_claude ;;
  esac
done

echo ""
echo "Deployed openspec-tools to $TARGET (${ENVS// /, })"
