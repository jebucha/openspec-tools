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

assert_validate_skill_step_6c() {
  echo "Test: validate skill step 6c (full-suite regression gate)"
  has "$VALIDATE_SKILL" "6c. Run Full-Suite Regression Gate" "step 6c heading present"
  local lb lc l7
  lb="$(line_of "$VALIDATE_SKILL" "6b. Run Executable Test Requirements")"
  lc="$(line_of "$VALIDATE_SKILL" "6c. Run Full-Suite Regression Gate")"
  l7="$(line_of "$VALIDATE_SKILL" "7. **Run Task Completion Checks**")"
  if [[ -n "$lb" && -n "$lc" && -n "$l7" && "$lb" -lt "$lc" && "$lc" -lt "$l7" ]]; then
    ok "6c ordered between 6b and step 7"
  else
    bad "6c ordered between 6b and step 7 (lines: 6b=${lb:-?} 6c=${lc:-?} step7=${l7:-?})"
  fi
  has "$VALIDATE_SKILL" "regression: enabled" "gate runs only when opted in"
  has "$VALIDATE_SKILL" "treated as absent" "malformed regression value degrades to absent"
  has "$VALIDATE_SKILL" "Executable: suite" "findings use the Executable: suite category"
  has "$VALIDATE_SKILL" "600-second default timeout" "600s default suite timeout"
  has "$VALIDATE_SKILL" "suite-timeout" "suite-timeout override named"
  has "$VALIDATE_SKILL" "one **Info** finding with the skip count" "suite skips are one Info finding"
  has "$VALIDATE_SKILL" "Full suite | Pass/Fail/Not run" "Full suite metrics row"
  has "$VALIDATE_SKILL" "Gate absent → no step, no \`Full suite\` row, no finding" "gate-absent no-op"
}

assert_audit_skill_regression_fields() {
  echo "Test: audit skill step 6d (regression gate fields check)"
  has "$AUDIT_SKILL" 'regression:' "gate field: regression named"
  has "$AUDIT_SKILL" 'suite-timeout:' "gate field: suite-timeout named"
  has "$AUDIT_SKILL" 'not exactly `enabled`' "malformed regression value defined"
  has "$AUDIT_SKILL" "not an integer number of seconds" "malformed suite-timeout defined"
  has "$AUDIT_SKILL" "one Info finding naming the malformed field" "single Info finding on malformed field"
  has "$AUDIT_SKILL" "Neither field is required" "neither field required"
  has "$AUDIT_SKILL" "produces no finding" "absence produces no finding"
}

assert_apply_audit_level_rule() {
  echo "Test: apply-audit skill 6d remediation (test-level selection rule)"
  has "$APPLY_SKILL" "lowest test level that genuinely exercises the declared outcome" "lowest-genuine-level rule"
  has "$APPLY_SKILL" "a single function or module" "unit level: single function or module"
  has "$APPLY_SKILL" "unit test" "unit test named"
  has "$APPLY_SKILL" "process, network, or persistence boundary" "boundary test"
  has "$APPLY_SKILL" "integration or e2e test" "integration or e2e level named"
  has "$APPLY_SKILL" "120-second per-block timeout" "generated Command must fit 120s"
  has "$APPLY_SKILL" "split the scenario or flag it for the human at the audit checkpoint" "split or flag when it cannot fit"
  has "$APPLY_SKILL" "The level is a generation rule, not a block field" "level is a generation rule"
  has "$APPLY_SKILL" "both the missing-block generation branch" "rule applies to both branches"
  has "$APPLY_SKILL" 'never add `regression: enabled`' "no auto-enable of the gate"
}

assert_audit_skill_pattern_d() {
  echo "Test: audit skill step 6d (mocked-subject fake-block pattern, Pattern D)"
  has "$AUDIT_SKILL" "Pattern D" "Pattern D named"
  has "$AUDIT_SKILL" "the unit under test is itself mocked or stubbed" "mocked subject defined"
  has "$AUDIT_SKILL" "the assertion verifies only the mock" "assertion verifies only the mock"
  has "$AUDIT_SKILL" "the scenario's outcome and the mocked subject side by side" "side-by-side evidence rule"
  has "$AUDIT_SKILL" "Mocking only the subject's dependencies does not trigger Pattern D" "dependency exception"
  has "$AUDIT_SKILL" 'excluded from the "Requirements with executable test requirements" numerator' "numerator exclusion"
}

assert_apply_audit_pattern_d_remediation() {
  echo "Test: apply-audit skill 6d remediation (Pattern D)"
  has "$APPLY_SKILL" "Pattern D" "Pattern D remediation named"
  has "$APPLY_SKILL" "rewrite the block so the subject runs for real" "rewrite so the subject runs for real"
  has "$APPLY_SKILL" "dependencies may remain mocked" "dependencies may remain mocked"
  has "$APPLY_SKILL" "or raise the test level" "or raise the test level"
}

assert_no_skill_writes_gate_fields() {
  echo "Test: no skill writes or modifies the gate fields (author-set only)"
  # apply-audit is the only skill that creates a Test Strategy section; it must
  # carry the explicit prohibition that it never adds the gate fields there.
  has "$APPLY_SKILL" 'never add `regression: enabled` or `suite-timeout:`' "apply-audit: never adds the gate fields"
  has "$APPLY_SKILL" "both fields are author-set only" "apply-audit: gate fields author-set only"
  # No skill may carry a bare instruction to write or set the gate fields into a
  # Test Strategy section. The apply-audit prohibition above is "never add ...",
  # which the write/set patterns below intentionally do not match.
  local f tag p
  for f in "$AUDIT_SKILL" "$APPLY_SKILL" "$VALIDATE_SKILL"; do
    tag="$(basename "$(dirname "$f")")"
    for p in 'add `regression: enabled` to the Test Strategy' 'set `regression: enabled`' 'add `suite-timeout:` to the Test Strategy' 'set `suite-timeout:`'; do
      lacks "$f" "$p" "$tag: no write/set instruction for $p"
    done
  done
}

ALL_TESTS=(assert_audit_skill_step_6d assert_apply_audit_remediation assert_validate_skill_step_6b assert_validate_skill_guardrails assert_validate_skill_step_6c assert_audit_skill_regression_fields assert_apply_audit_level_rule assert_audit_skill_pattern_d assert_apply_audit_pattern_d_remediation assert_no_skill_writes_gate_fields)

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
