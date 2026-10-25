# Tasks

## 1. Dogfood test harness

- [x] 1.1 Create `tests/test_skill_content.sh` — plain bash with named test functions and single-name dispatch (`bash tests/test_skill_content.sh <function>`), ok/bad assertion style mirroring `tests/deploy_test.sh` — with four functions: `assert_audit_skill_step_6d` (audit skill contains step 6d with the Coverage Metrics row), `assert_apply_audit_remediation` (apply-audit skill contains the 6d remediation path), `assert_validate_skill_step_6b` (validate skill contains the executable step between structural coverage and task completion), `assert_validate_skill_guardrails` (old "Test checks are structural" guardrail absent, executable-runs guardrail block present); verify dispatch runs each function and all four exit non-zero pre-skill-edits (expected red)
- [x] 1.2 Verify the harness integrates with the existing suite: `bash tests/deploy_test.sh && bash tests/test_skill_content.sh` runs both, and `deploy_test.sh` still exits 0 on its own

## 2. Audit skill (skills/openspec-audit-change)

- [x] 2.1 Insert step 6d "Executable test requirement presence" after 6c: per-scenario decision table (exempt / missing block / incomplete / malformed ID / fake), Warning (VL-n) severities with a single Info for missing Test Strategy, the three fake-block patterns (static-only command, existential pass criterion, behavior-unrelated command) with the side-by-side evidence rule and the content-assertion boundary rule; verify `bash tests/test_skill_content.sh assert_audit_skill_step_6d` exits 0
- [x] 2.2 Add the forward-reference exemption to 4b: block `File` paths and Test Strategy file references are created by `/opsx-apply` and are exempt from referenced-file existence checks; verify by re-reading the 4b section and confirming the exemption names both locations
- [x] 2.3 Add the "Requirements with executable test requirements | X (Y%)" row to the Coverage Metrics table in step 9 and to both output examples (clean audit and audit-with-errors); verify the row appears in all three places via grep
- [x] 2.4 Bump skill version 1.2 → 1.3 in the frontmatter and update `skills/openspec-audit-change/README.md` (new 6d check in the audit categories, metrics row, forward-reference exemption); verify frontmatter and README reflect 1.3 and 6d

## 3. Apply-audit skill (skills/openspec-apply-audit)

- [x] 3.1 Add the 6d remediation path to step 5 under Warnings → Validity: generate a missing block from the scenario's WHEN/THEN with File/Command derived from the Test Strategy; dual-branch fake-block remediation (replace with a genuine assertion, or delete when the scenario is actually exempt); Test Strategy section created before any block generation when absent; verify `bash tests/test_skill_content.sh assert_apply_audit_remediation` exits 0
- [x] 3.2 Bump skill version 1.0 → 1.1 in the frontmatter and update `skills/openspec-apply-audit/README.md` with the new remediation capability; verify frontmatter and README reflect 1.1

## 4. Validate skill (skills/openspec-validate-change)

- [x] 4.1 Insert step 6b "Run Executable Test Requirements" between step 6 (renamed 6a "Structural Test Coverage") and step 7: parse Test Requirement blocks from the change's spec files, read Test Strategy from design.md, check typed prerequisites (`env:`/`file:`/`cmd:`; untyped → Info note + proceed), verify file/test ID exists (missing → distinct Error), run the Command verbatim from project root, classify by the declared Pass criterion (default: exit 0 + no skip markers; per-runner-family markers for pytest/jest/go/cargo; unknown runner → exit code only, noted), skipped/xfail → Error, unmet prerequisite → distinct "prerequisite unmet" Error, scenario without block → structural fallback, zero-block change → one Info finding; if `add-validation-linting` has landed, align step references with its renumbering; verify `bash tests/test_skill_content.sh assert_validate_skill_step_6b` exits 0
- [x] 4.2 Replace the guardrail "Test checks are structural" with an executable-runs guardrail block (declared-only execution — verbatim, never synthesized or broadened; read-only wrt the codebase — no installs, no config/env edits; hard 120s timeout per command → Error with partial output; evidence = exit code + last 20 lines; at most 25 commands prioritized by spec order, remainder summarized; findings use the normal VD- sequence) and reconcile the "Non-destructive: Read-only analysis" line in Fluid Workflow Integration with it; verify `bash tests/test_skill_content.sh assert_validate_skill_guardrails` exits 0
- [x] 4.3 Add the "Executable tests passed | X/Y (Z%)" row to the Coverage Metrics table and add an "Executable: tests" finding to the output examples (a satisfied or Info-level row in the Pass example, a failed-command Error in the Fail example); verify the row and category appear in the report template and both examples via grep; if `add-validation-linting` has landed, align the example edits with its `Executable: lint` rows (its tasks 4.1/4.2 edit the same Pass/Fail examples)
- [x] 4.4 Bump skill version 1.0 → 1.1 in the frontmatter and update `skills/openspec-validate-change/README.md` (executable test execution as a validation dimension, Test Requirement/Test Strategy convention summary, guardrail change); verify frontmatter and README reflect 1.1 and the new step

## 5. Integration

- [x] 5.1 Run the full suite `bash tests/deploy_test.sh && bash tests/test_skill_content.sh` and verify both exit 0 — the deploy regression confirms the edited skill files still deploy byte-for-byte unchanged to all targets
- [x] 5.2 Cross-check the artifacts against the convention: re-read this change's `specs/executable-test-requirements/spec.md` and `design.md` and verify the four Test Requirement blocks (T-EXECUTABLE-TEST-REQUIREMENTS-001…004) have all four fields with matching File/Command pairs, and that the Test Strategy section's full-suite command is exactly what task 5.1 runs

## Workflow follow-up

- Run `/opsx-audit add-executable-test-requirements` in a fresh session — first real exercise of step 6d and the forward-reference exemption against this change's own artifacts (blocks point at test functions created in task group 1, so post-apply the audit should show no 6d Warnings for the four declared blocks and no 4b findings for the declared test paths; unblocked behavior-changing scenarios in this change's own specs are expected to draw 6d "missing test requirement" Warnings — the convention is demonstrated on the declared blocks, not fully self-applied)
- Run `/opsx-validate add-executable-test-requirements` in a fresh session with a model that did not write the code — first real exercise of step 6b, executing the four declared blocks
