# Tasks

## 1. New "Executable Test Requirements" section

- [x] 1.1 Add a new top-level `## Executable Test Requirements` section to `README.md` between `## Validation Dimensions` and `## Audit Persistence`, stating that validation is judged by exit-code evidence, not model judgment, and describing the Test Requirement block (four fields under a `#### Scenario:`: `ID` matching `T-<CAPABILITY-UPPERCASE>-<NNN>`, `File` as `path::test_id`, `Command` verbatim from project root, `Pass` machine-checkable) — verify the four field names and ID format match `skills/openspec-validate-change/SKILL.md` step 6b word for word
- [x] 1.2 In the new section, document the `## Test Strategy` section in design.md (declares runner, full-suite command, and typed prerequisites `env: <VAR>` / `file: <path>` / `cmd: <probe>` once per change; blocks reference it instead of repeating environment details) — verify the three prerequisite types match `openspec/specs/executable-test-requirements/spec.md`
- [x] 1.3 In the new section, list the exemptions (docs, config, contract-preserving refactor), the three fake-block patterns (static-only command, existential pass criterion, behavior-unrelated command), and the boundary rule that a content assertion (grep/diff) verifying the scenario's declared outcome IS a Test Requirement — verify the ordering (patterns, then boundary rule) matches the spec, and the fake-block list matches `skills/openspec-audit-change/SKILL.md` step 6d
- [x] 1.4 In the new section, include the worked example reusing the existing `add-data-export` sample identity (`T-CSV-EXPORT-001`, `tests/export.test.ts`, command, "exit code 0") as a fenced block showing a scenario with its Test Requirement — verify the example ID and file match the example output already in `skills/openspec-validate-change/README.md`
- [x] 1.5 In the new section, add the guardrail bullets: declared-only execution (never synthesized, broadened, or edited), no dependency installs or config/environment edits, hard 120-second timeout with partial-output Error, at most 25 commands per execution prioritized by spec order with the remainder summarized, and that findings cite the exit code plus last 20 lines of output — verify each bullet's numbers and phrasing match `skills/openspec-validate-change/SKILL.md` guardrails
- [x] 1.6 In the new section, name the validate report's new Coverage Metrics row (`Executable tests passed | X/Y (Z%)`) and the `Executable: tests` finding category (normal VD- sequence) — verify the row label and category wording match `skills/openspec-validate-change/SKILL.md` exactly

## 2. Table rewrites

- [x] 2.1 Rewrite the Test coverage cell in the Validation Dimensions table to describe both checks — scenarios with a Test Requirement block are verified by execution (declared command run; failures, skipped/xfail tests, missing file or test ID, and unmet prerequisites are Errors), all other scenarios keep the structural coverage check — verify the 6a/6b split and "skipped test asserts nothing" rule match `skills/openspec-validate-change/SKILL.md` step 6
- [x] 2.2 Rewrite the Validity cell in the Audit Categories table to include "behavior-changing scenarios carry genuine Test Requirement blocks" alongside the existing checks — verify the phrasing covers the 6d decision table's outcomes (missing/incomplete/malformed/fake → Warning) without restating the table
- [x] 2.3 Add a one-clause note to the apply-audit row in the workflow table (line 16) and to `openspec-apply-audit/` in the Skills table (line 85) that it generates missing Test Requirement blocks and creates the `## Test Strategy` section before generating blocks — verify the clause matches the 6d remediation rules in `skills/openspec-apply-audit/SKILL.md`

## 3. Small edits

- [x] 3.1 Extend the Validate checkpoint bullet (line 37) to note execution of declared test requirements alongside spec compliance, test coverage, task completion, code quality, and regression safety — verify the bullet still lists all five dimensions plus execution
- [x] 3.2 Add a one-clause note to the Session 1 row of the Typical Session table that the proposal also carries Test Requirement blocks and a Test Strategy, making the later validate verdict evidence-based — verify the session count and model assignments are unchanged
- [x] 3.3 Add a `tests/` entry with `test_skill_content.sh` to the Project Structure tree after the `openspec/` entry and before `deploy.sh` — verify `tests/test_skill_content.sh` exists at the repo root

## 4. Integration verification

- [x] 4.1 Cross-check the finished README against the three updated skill files and the `executable-test-requirements` spec: grep for `T-<CAPABILITY-UPPERCASE>-<NNN>`, `::`, `Test Strategy`, `env:` / `file:` / `cmd:`, `120`, `25 commands`, `Executable tests passed`, and `Executable: tests` in `README.md` and confirm every occurrence matches the skill/spec wording — verify no occurrence contradicts a skill file
- [x] 4.2 Confirm the README still satisfies the `docs-consistency` spec scenarios (Skills table and Project Structure tree use `skills/` prefix; no new "Files" or "Deployment" sections added to any per-skill README, since none are edited) — verify by re-reading the sections the spec names
- [x] 4.3 Run `bash tests/test_skill_content.sh` and confirm it still passes (skill content untouched by this change, so it must be green before and after) — verify exit code 0
- [x] 4.4 Re-read `README.md` top to bottom for section ordering, table shape (row/column counts preserved except the intended additions), and link/anchor correctness — verify the new section sits between Validation Dimensions and Audit Persistence and no existing heading was renamed
