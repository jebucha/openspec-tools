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
    --gemini)   FORCE_ENV="gemini" ;;
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
  [[ -d "$TARGET/.gemini" ]]   && ENVS="${ENVS:+$ENVS }gemini"
fi

if [[ -z "$ENVS" ]]; then
  echo "Error: No supported environment found in $TARGET"
  echo ""
  echo "Expected one of: .opencode/, .kiro/, .claude/, .gemini/"
  echo ""
  echo "Initialize one of:"
  echo "  openspec init     → creates .opencode/"
  echo "  kiro init         → creates .kiro/"
  echo "  mkdir .claude     → creates .claude/"
  echo "  mkdir .gemini     → creates .gemini/"
  echo ""
  echo "Or force a target: --opencode, --kiro, --claude, --gemini"
  exit 1
fi

deploy_opencode() {
  mkdir -p "$TARGET/.opencode/commands"
  for cmd in "$SCRIPT_DIR"/commands/*.md; do
    [[ -f "$cmd" ]] || continue
    cp "$cmd" "$TARGET/.opencode/commands/"
    echo "  [opencode] command: $(basename "$cmd")"
  done

  for skill_dir in "$SCRIPT_DIR"/skills/*/; do
    [[ -d "$skill_dir" ]] || continue
    skill_name="$(basename "$skill_dir")"
    mkdir -p "$TARGET/.opencode/skills/$skill_name"
    cp "$skill_dir"* "$TARGET/.opencode/skills/$skill_name/" 2>/dev/null || true
    echo "  [opencode] skill: $skill_name"
  done
}

deploy_kiro() {
  mkdir -p "$TARGET/.kiro/prompts"
  for cmd in "$SCRIPT_DIR"/commands/*.md; do
    [[ -f "$cmd" ]] || continue
    base="$(basename "$cmd" .md)"
    cp "$cmd" "$TARGET/.kiro/prompts/${base}.prompt.md"
    echo "  [kiro] prompt: ${base}.prompt.md"
  done

  for skill_dir in "$SCRIPT_DIR"/skills/*/; do
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
  for cmd in "$SCRIPT_DIR"/commands/*.md; do
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
  for skill_dir in "$SCRIPT_DIR"/skills/*/; do
    [[ -d "$skill_dir" ]] || continue
    skill_name="$(basename "$skill_dir")"
    mkdir -p "$TARGET/.claude/skills/$skill_name"
    cp "$skill_dir"* "$TARGET/.claude/skills/$skill_name/" 2>/dev/null || true
    echo "  [claude] skill: $skill_name"
  done
}

deploy_gemini() {
  # Deploy commands: convert .md to .toml
  mkdir -p "$TARGET/.gemini/commands/opsx"
  for cmd in "$SCRIPT_DIR"/commands/*.md; do
    [[ -f "$cmd" ]] || continue
    base="$(basename "$cmd" .md)"
    # Strip "opsx-" prefix from filename
    name="${base#opsx-}"
    # Extract description: first non-empty, non-heading line
    content="$(cat "$cmd")"
    description=""
    while IFS= read -r line; do
      [[ -z "$line" ]] && continue
      [[ "$line" =~ ^[#[:space:]] ]] && continue
      description="$line"
      break
    done <<< "$content"
    # Escape triple quotes in content for valid TOML
    escaped_content="${content//\"\"\"/\\\"\\\"\\\"}"
    # Write TOML file
    cat > "$TARGET/.gemini/commands/opsx/${name}.toml" << TOML_EOF
description = "${description}"

prompt = """
${escaped_content}
"""
TOML_EOF
    echo "  [gemini] command: opsx/${name}.toml"
  done

  # Deploy skills: same structure as opencode
  for skill_dir in "$SCRIPT_DIR"/skills/*/; do
    [[ -d "$skill_dir" ]] || continue
    skill_name="$(basename "$skill_dir")"
    mkdir -p "$TARGET/.gemini/skills/$skill_name"
    cp "$skill_dir"* "$TARGET/.gemini/skills/$skill_name/" 2>/dev/null || true
    echo "  [gemini] skill: $skill_name"
  done
}

# Deploy to each detected/forced environment
for env in $ENVS; do
  case "$env" in
    opencode) deploy_opencode ;;
    kiro)     deploy_kiro ;;
    claude)   deploy_claude ;;
    gemini)   deploy_gemini ;;
  esac
done

echo ""
echo "Deployed openspec-tools to $TARGET (${ENVS// /, })"
