#!/usr/bin/env bash
# Content assertions for the owned skills — executable-test-requirements change.
#
# Run: bash tests/test_skill_content.sh            # all checks
#      bash tests/test_skill_content.sh <function> # a single named check
# Exits 0 if all assertions pass, 1 otherwise.
set -u

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
AUDIT_SKILL="$REPO_ROOT/skills/openspec-audit-change/SKILL.md"
APPLY_SKILL="$REPO_ROOT/skills/openspec-apply-audit/SKILL.md"
VALIDATE_SKILL="$REPO_ROOT/skills/openspec-validate-change/SKILL.md"

PASS=0
FAIL=0

ok()   { PASS=$((PASS+1)); echo "  ok: $1"; }
bad()  { FAIL=$((FAIL+1)); echo "  FAIL: $1"; }

has() { # has <file> <fixed-string> <description>
  if grep -qF -- "$2" "$1"; then ok "$3"; else bad "$3 (missing: '$2')"; fi
}

lacks() { # lacks <file> <fixed-string> <description>
  if grep -qF -- "$2" "$1"; then bad "$3 (should not contain: '$2')"; else ok "$3"; fi
}

line_of() { # line_of <file> <fixed-string> → 1-based line number, or empty
  grep -nF -- "$2" "$1" | head -1 | cut -d: -f1
}

assert_audit_skill_step_6d() {
  echo "Test: audit skill step 6d (executable test requirement presence)"
  has "$AUDIT_SKILL" "6d. Executable test requirement presence" "step 6d heading present"
  has "$AUDIT_SKILL" "exempt" "decision table: exempt scenarios produce no finding"
  has "$AUDIT_SKILL" "missing test requirement" "decision table: missing block Warning"
  has "$AUDIT_SKILL" "incomplete block" "decision table: incomplete block Warning"
  has "$AUDIT_SKILL" "malformed ID" "decision table: malformed ID Warning"
  has "$AUDIT_SKILL" "not a runtime behavior assertion" "decision table: fake block Warning"
  has "$AUDIT_SKILL" "Static-only command" "fake pattern A named"
  has "$AUDIT_SKILL" "Existential pass criterion" "fake pattern B named"
  has "$AUDIT_SKILL" "Behavior-unrelated command" "fake pattern C named"
  has "$AUDIT_SKILL" "side by side" "side-by-side evidence rule present"
  has "$AUDIT_SKILL" "content assertion" "content-assertion boundary rule present"
  has "$AUDIT_SKILL" "## Test Strategy" "missing Test Strategy noted"
  has "$AUDIT_SKILL" "Requirements with executable test requirements" "Coverage Metrics row present"
  has "$AUDIT_SKILL" "T-<CAPABILITY-UPPERCASE>-<NNN>" "ID format documented"
  has "$AUDIT_SKILL" "Forward-reference exemption" "4b forward-reference exemption present"
  has "$AUDIT_SKILL" "file references in a design.md" "exemption names Test Strategy file references"
}

assert_apply_audit_remediation() {
  echo "Test: apply-audit skill 6d remediation path"
  has "$APPLY_SKILL" "missing test requirement" "missing-block remediation named"
  has "$APPLY_SKILL" "WHEN/THEN" "block generated from the scenario's WHEN/THEN"
  has "$APPLY_SKILL" "Test Strategy" "File/Command derived from the Test Strategy"
  has "$APPLY_SKILL" "before generating any block" "Test Strategy created first when absent"
  has "$APPLY_SKILL" "delete the block" "dual-branch: delete for actually-exempt scenario"
  has "$APPLY_SKILL" "note the exemption" "dual-branch: exemption noted"
}

assert_validate_skill_step_6b() {
  echo "Test: validate skill step 6b (run executable test requirements)"
  has "$VALIDATE_SKILL" "6a. Structural Test Coverage" "step 6 renamed 6a"
  has "$VALIDATE_SKILL" "6b. Run Executable Test Requirements" "step 6b heading present"
  local la lb l7
  la="$(line_of "$VALIDATE_SKILL" "6a. Structural Test Coverage")"
  lb="$(line_of "$VALIDATE_SKILL" "6b. Run Executable Test Requirements")"
  l7="$(line_of "$VALIDATE_SKILL" "7. **Run Task Completion Checks**")"
  if [[ -n "$la" && -n "$lb" && -n "$l7" && "$la" -lt "$lb" && "$lb" -lt "$l7" ]]; then
    ok "6b ordered between 6a and step 7"
  else
    bad "6b ordered between 6a and step 7 (lines: 6a=${la:-?} 6b=${lb:-?} step7=${l7:-?})"
  fi
  has "$VALIDATE_SKILL" "Test Strategy" "Test Strategy read from design.md"
  has "$VALIDATE_SKILL" "verbatim" "commands run verbatim"
  has "$VALIDATE_SKILL" "120-second timeout" "hard 120s timeout"
  has "$VALIDATE_SKILL" "prerequisite unmet" "unmet prerequisite Error"
  has "$VALIDATE_SKILL" "No executable test requirements declared" "zero-block Info finding"
  has "$VALIDATE_SKILL" "Executable: tests" "findings use the Executable: tests category"
  has "$VALIDATE_SKILL" "Executable tests passed" "Coverage Metrics row: Executable tests passed"
  has "$VALIDATE_SKILL" "env: <VAR>" "typed prerequisite: env"
  has "$VALIDATE_SKILL" "file: <path>" "typed prerequisite: file"
  has "$VALIDATE_SKILL" "cmd: <probe>" "typed prerequisite: cmd"
  has "$VALIDATE_SKILL" "missing file or test ID" "missing file/test ID is a distinct Error"
  has "$VALIDATE_SKILL" "skipped or xfail" "skipped/xfail tests are Errors"
}

assert_validate_skill_guardrails() {
  echo "Test: validate skill guardrails (structural-only replaced by executable-runs)"
  lacks "$VALIDATE_SKILL" "Test checks are structural" "old structural-only guardrail absent"
  has "$VALIDATE_SKILL" "Declared-only execution" "executable-runs guardrail: declared-only"
  has "$VALIDATE_SKILL" "120-second timeout" "executable-runs guardrail: 120s timeout"
  has "$VALIDATE_SKILL" "25 commands" "executable-runs guardrail: command cap"
  has "$VALIDATE_SKILL" "last 20 lines" "executable-runs guardrail: evidence format"
  has "$VALIDATE_SKILL" "Read-only with respect to the codebase" "executable-runs guardrail: no codebase mutation"
  has "$VALIDATE_SKILL" "Stable IDs for executable findings" "executable-runs guardrail: stable VD- IDs"
}

ALL_TESTS=(assert_audit_skill_step_6d assert_apply_audit_remediation assert_validate_skill_step_6b assert_validate_skill_guardrails)

if [[ $# -eq 0 ]]; then
  for t in "${ALL_TESTS[@]}"; do "$t"; done
else
  for name in "$@"; do
    if [[ ! "$name" =~ ^assert_ ]] || ! declare -F "$name" >/dev/null 2>&1; then
      echo "Usage: bash tests/test_skill_content.sh [function...]"
      echo "Known functions: ${ALL_TESTS[*]}"
      echo "  FAIL: unknown test name '$name'"
      FAIL=$((FAIL+1))
      continue
    fi
    "$name"
  done
fi

echo ""
echo "Results: $PASS passed, $FAIL failed"
[[ "$FAIL" -eq 0 ]]
