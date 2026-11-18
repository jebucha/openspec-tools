# Tasks

## 1. Audit skill (skills/openspec-audit-change)

- [x] 1.1 Remove step 8d "Security surface awareness" from Coherence. Drop "security surface omissions" from Coherence's Warning severity line. Verify that `grep -n "8d\|security surface" skills/openspec-audit-change/SKILL.md` returns only the "Security checks are contextual" guardrail line (rewritten in 1.5) and no step 8d content.
- [x] 1.2 Insert step "9. Run Security Checks" between Coherence and Produce Structured Output, and renumber steps 9–12 to 10–13. Update the 10a–10d sub-labels to 11a–11d and fix every internal cross-reference. Verify by re-reading steps 9–13 and confirming the sequence and sub-labels are consistent. Confirm the renumbered regression-detection step (11a–11d) matches findings by stable ID across all categories, so `SC-` IDs are included without special-casing.
- [x] 1.3 Write the always-run checks: 9a Secrets in artifacts (Error) and 9b Secret handling planned (Warning). Add the pattern set and placeholder exemptions from design D5 under 9a, and note that 9a and 9b run on every change. Verify by re-reading 9a and 9b against spec requirement "Always-run secrets checks at audit".
- [x] 1.4 Write the contextual checks under one trigger line (auth, user input, data storage, external communication, secrets, permissions, crypto): 9c Untrusted input (Warning), 9d Weakened controls (Warning), and 9e Escalation to `/opsx-security-audit` (Info, one per change, narrower trigger: auth, crypto, permissions, or secrets). Add the step's severity summary. Verify against spec requirement "Contextual security checks at audit".
- [x] 1.5 Update the Output Constraints prefix list to include `SC-1` (Security). Rewrite the "Security checks are contextual" guardrail: 9a and 9b always run, and 9c–9e follow the trigger list. Add the guardrail "Never reproduce secret values: evidence is file, line, and pattern type only". Add one `SC-` row to the "Audit with errors" example. Verify all of these with grep.
- [x] 1.6 Update the description and the intro bullet list in the frontmatter so "security" is a listed category. Bump the version from 1.4 to 1.5. Update `skills/openspec-audit-change/README.md`: change "five categories" to six, move the Security surface bullet into a new `### Security (SC-)` section, and point the guardrail at 9a–9e. Verify the frontmatter and README with grep.
- [x] 1.7 Add `assert_audit_skill_security_category`, which checks:
  - the step 9 heading, `SC-` in Output Constraints, and the 9a–9e names
  - the Error, Warning, and Info severities
  - the always-run wording and the trigger list

  Add `assert_audit_skill_coherence_no_security`, which checks that "Security surface awareness" is absent and that "Run Security Checks" comes after "Run Coherence Checks". Register both in `ALL_TESTS`. Verify that `bash tests/test_skill_content.sh assert_audit_skill_security_category assert_audit_skill_coherence_no_security` exits 0.

## 2. Validate skill (skills/openspec-validate-change)

- [x] 2.1 Restructure step 8 as "8. Run Code Quality and Security Checks", with 8a Code quality (existing content, still Info-only) and 8b Security. Do not renumber top-level steps. Verify by re-reading step 8 and confirming that steps 9–13 are unchanged.
- [x] 2.2 Write the 8b secret scan:
  - It scans the added lines (obtained via `git diff -U0`) and new files (read in full) from step 4's changed-file set, using the pattern set copied verbatim from audit 9a.
  - It flags newly added credential files and exempts template variants.
  - Each hit is an Error with Category `Security`.
  - An already-installed scanner may supplement the scan, with redaction only. Never install one, and a missing scanner produces no finding.

  Verify against the spec requirements "Validation scans the diff for secrets" and "Secret scanning never installs tools".
- [x] 2.3 Write the 8b code-level checks (Warning): string-built shell, SQL, eval, or paths from external input; disabled TLS or auth; unpinned new dependencies; remote scripts piped to a shell. Add the plan follow-through check (Warning): the design's stated secret source and validation, plus unresolved `SC-` findings from the newest audit without a `## Resolved` header. Add one escalation Info. Verify against spec requirement "Validation checks code-level security and plan follow-through".
- [x] 2.4 Add the guardrails "Never reproduce secret values" and "Security check is best-effort and scoped to changed files", and extend the no-install guardrail to cover scanners. Add a `Security` Error row to the Fail output example, with evidence in the form `file:line, pattern type` and no value. Verify with grep.
- [x] 2.5 Bump the version from 1.2 to 1.3. Update `skills/openspec-validate-change/README.md`: change "five dimensions" to six and add a Security dimension row. Verify the frontmatter and README with grep.
- [x] 2.6 Add `assert_validate_skill_security_check`, which checks:
  - the 8b heading and Category `Security`
  - the Error for secrets, the credential-file list, and the `.env.example` exemption
  - the TLS, injection, and pinning Warnings, and the follow-through wording

  Add `assert_validate_skill_no_scanner_install`, which checks the never-install wording and the redaction requirement. Add `assert_secret_pattern_set`, which checks that every pattern marker and placeholder exemption appears in both the audit and validate skills. Add `assert_security_escalation`, which checks that `/opsx-security-audit` appears in both skills with a one-per-change Info. Register all four. Verify that `bash tests/test_skill_content.sh assert_validate_skill_security_check assert_validate_skill_no_scanner_install assert_secret_pattern_set assert_security_escalation` exits 0.

## 3. Apply-audit skill (skills/openspec-apply-audit)

- [x] 3.1 Add a *Security* block to the remediation plan:
  - **Error, secret in artifact:** replace it with an env-var or secrets-manager reference, tell the user to rotate the credential, and never echo the value.
  - **Warnings:**
    - Secret handling not planned: add the source to the design and add a task.
    - Untrusted input: add a validation task and a design note.
    - Weakened control: ask the user to justify it in the design or remove it, and never decide on their behalf.
  - **Info, escalation:** no fix needed. Note it in the follow-up offers.

  Update the finding-ID parsing line (currently "Parse findings by their stable IDs (AC-1, CM-1, etc.)") to include `SC-1` so Security findings are recognized. Remove "Security surface omissions" from the Coherence warnings. Verify by re-reading the remediation section.
- [x] 3.2 Add the guardrail "Never reproduce secret values in the plan, diff summary, or resolution header". Bump the version from 1.2 to 1.3 and update `skills/openspec-apply-audit/README.md`. Verify with grep.
- [x] 3.3 Add `assert_apply_audit_security_remediation`, which checks the rotate wording, the env-var reference, the ask-user rule for weakened controls, and that "Security surface omissions" is absent from Coherence. Add `assert_skills_never_reproduce_secrets`, which checks that the never-reproduce guardrail appears in all three skills. Register both. Verify that `bash tests/test_skill_content.sh assert_apply_audit_security_remediation assert_skills_never_reproduce_secrets` exits 0.

## 4. Top-level docs

- [x] 4.1 Update the Audit Categories section of `README.md`:
  - Change "five dimensions" to six.
  - Add a Security row (secrets in artifacts, secret handling, untrusted input, weakened controls, escalation).
  - Remove "security surface covered" from the Coherence row.

  Update Validation Dimensions in the same way with a Security row. Verify by reading both tables.
- [x] 4.2 Add a CHANGELOG entry covering:
  - The new Security category.
  - The validate Security check.
  - The apply-audit remediation.
  - Version bumps: audit 1.5, validate 1.3, apply-audit 1.3.
  - The stable-ID note: former Coherence security findings (`CO-n`) are now `SC-n`, so regression detection will not match resolved `CO-n` security findings from earlier audits against new `SC-n` IDs.

  Verify the entry is present.
- [x] 4.3 Add `assert_readme_security_category`, which checks that README.md contains "six" category wording and a `**Security**` row, that the Coherence row lacks "security surface", and that the audit skill README has "### Security (SC-)", and that `skills/openspec-validate-change/README.md` lists the Security dimension. Register it. Verify that `bash tests/test_skill_content.sh assert_readme_security_category` exits 0.

## 5. Integration

- [x] 5.1 Run the full suite, `bash tests/deploy_test.sh && bash tests/test_skill_content.sh`, and confirm both exit 0. This confirms that the existing assertions survived the audit renumbering and that the skills still deploy byte-for-byte.
- [x] 5.2 Count the lines in the audit SKILL.md and compare with the pre-change count of 461. Confirm the net growth is roughly 50 lines or fewer, per the design's "not significantly extending" trade-off. If it is larger, tighten the wording before closing.

## Workflow follow-up

- Run `/opsx-audit add-security-audit-category` in a fresh session with a different model. This is a dogfood run: the new 9a check runs against this change's own artifacts, and the pattern examples in design.md use only prefixes, never full tokens, so they should not trip it. If they do, that is a false positive to tune.
- Run `/opsx-validate add-security-audit-category` in a fresh session with a model that did not write the code. The regression gate is enabled.
- If `add-validation-linting` lands first (it edits the deployed `.opencode` copy, not the source), rebase step 8 to match its renumbering. The 8a/8b structure is unaffected.
