#!/usr/bin/env bash
# Tests for deploy.sh — qwen-deploy spec requirements, argument handling,
# and regression sanity for the other deploy targets.
#
# Run: bash tests/deploy_test.sh
# Exits 0 if all assertions pass, 1 otherwise.
set -u

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
DEPLOY="$REPO_ROOT/deploy.sh"
WORK="$(mktemp -d)"
trap 'rm -rf "$WORK"' EXIT

PASS=0
FAIL=0

ok()   { PASS=$((PASS+1)); echo "  ok: $1"; }
bad()  { FAIL=$((FAIL+1)); echo "  FAIL: $1"; }

check() { # check <description> <command...>
  local desc="$1"; shift
  if "$@" >/dev/null 2>&1; then ok "$desc"; else bad "$desc"; fi
}

assert_eq() { # assert_eq <description> <expected> <actual>
  if [[ "$2" == "$3" ]]; then ok "$1"; else bad "$1 (expected: '$2', got: '$3')"; fi
}

assert_contains() { # assert_contains <description> <needle> <haystack>
  if [[ "$3" == *"$2"* ]]; then ok "$1"; else bad "$1 (missing: '$2')"; fi
}

run_deploy() { # run_deploy [flags...] <target> — sets RC and OUT
  OUT="$(bash "$DEPLOY" "$@" 2>&1)"
  RC=$?
}

# Source inventory — assert against whatever the repo ships
COMMANDS=()
for f in "$REPO_ROOT"/commands/*.md; do [[ -f "$f" ]] && COMMANDS+=("$(basename "$f")"); done
SKILLS=()
for d in "$REPO_ROOT"/skills/*/; do [[ -d "$d" ]] && SKILLS+=("$(basename "$d")"); done

if [[ "${#COMMANDS[@]}" -eq 0 || "${#SKILLS[@]}" -eq 0 ]]; then
  echo "FAIL: empty source inventory (commands=${#COMMANDS[@]}, skills=${#SKILLS[@]})"
  exit 1
fi

echo "Test: Qwen auto-detection"
T="$WORK/auto-detect"; mkdir -p "$T/.qwen"
run_deploy "$T"
assert_eq "deploy with .qwen/ present exits 0" "0" "$RC"
assert_contains "summary lists qwen" "(qwen)" "$OUT"
for c in "${COMMANDS[@]}"; do
  check "command $c deployed" test -f "$T/.qwen/commands/$c"
done

T="$WORK/no-detect"; mkdir -p "$T"
run_deploy "$T"
assert_eq "deploy with no env dir exits 1" "1" "$RC"
assert_contains "error message shown" "No supported environment" "$OUT"
assert_contains "error lists .qwen/" ".qwen/" "$OUT"
assert_contains "error lists --qwen" "--qwen" "$OUT"
check "no .qwen created" test ! -e "$T/.qwen"

echo "Test: Qwen force flag"
T="$WORK/force"; mkdir -p "$T/.opencode"
run_deploy --qwen "$T"
assert_eq "force deploy exits 0" "0" "$RC"
assert_contains "only qwen deployed" "(qwen)" "$OUT"
check ".qwen/commands created" test -d "$T/.qwen/commands"
check ".opencode not touched" test ! -e "$T/.opencode/commands"

echo "Test: Commands deployed as-is"
T="$WORK/as-is"; mkdir -p "$T/.qwen"
run_deploy "$T"
for c in "${COMMANDS[@]}"; do
  if cmp -s "$REPO_ROOT/commands/$c" "$T/.qwen/commands/$c"; then
    ok "command $c content unchanged"
  else
    bad "command $c content changed"
  fi
done

echo "Test: Skills deployed unchanged"
T="$WORK/skills"; mkdir -p "$T/.qwen"
run_deploy "$T"
for s in "${SKILLS[@]}"; do
  if diff -r "$REPO_ROOT/skills/$s" "$T/.qwen/skills/$s" >/dev/null 2>&1; then
    ok "skill $s unchanged"
  else
    bad "skill $s differs"
  fi
done

echo "Test: Deployment progress output"
T="$WORK/progress"; mkdir -p "$T/.qwen"
run_deploy "$T"
for c in "${COMMANDS[@]}"; do
  assert_contains "progress line for $c" "  [qwen] command: $c" "$OUT"
done
for s in "${SKILLS[@]}"; do
  assert_contains "progress line for $s" "  [qwen] skill: $s" "$OUT"
done

echo "Test: Unknown flag rejection"
T="$WORK/unknown-flag"; mkdir -p "$T/.qwen"
run_deploy --gemini "$T"
assert_eq "unknown flag exits 1" "1" "$RC"
assert_contains "error names the flag" "Unknown option '--gemini'" "$OUT"
assert_contains "error lists valid options" "--qwen" "$OUT"
check "nothing deployed" test ! -e "$T/.qwen/commands"

echo "Test: Other targets still work (regression sanity)"
T="$WORK/opencode"; mkdir -p "$T/.opencode"
run_deploy "$T"
assert_eq "opencode deploy exits 0" "0" "$RC"
for c in "${COMMANDS[@]}"; do
  check "opencode: $c" test -f "$T/.opencode/commands/$c"
done

T="$WORK/kiro"; mkdir -p "$T/.kiro"
run_deploy "$T"
assert_eq "kiro deploy exits 0" "0" "$RC"
for c in "${COMMANDS[@]}"; do
  base="${c%.md}"
  check "kiro: ${base}.prompt.md" test -f "$T/.kiro/prompts/${base}.prompt.md"
done

T="$WORK/claude"; mkdir -p "$T/.claude"
run_deploy "$T"
assert_eq "claude deploy exits 0" "0" "$RC"
for c in "${COMMANDS[@]}"; do
  base="${c%.md}"
  prefix="${base%%-*}"
  rest="${base#*-}"
  check "claude: $prefix/$rest.md" test -f "$T/.claude/commands/$prefix/$rest.md"
done

echo ""
echo "Results: $PASS passed, $FAIL failed"
[[ "$FAIL" -eq 0 ]]
