# Design

## Context

See proposal.md — Why. Current state that shapes this design:

- Validate runs each declared Test Requirement block as step 6b (120s per-block timeout, 25-command cap, declared-only execution, read-only wrt the codebase, Category `Executable: tests`, row "Executable tests passed | X/Y (Z%)"). Step 6a is the structural check; step 7 is task completion.
- Audit step 6d checks block presence and fakes (patterns A–C: static-only command, existential pass criterion, behavior-unrelated command), with a single-Info discipline for Test Strategy issues and a forward-reference exemption for block/Test Strategy file paths.
- Apply-audit generates a missing block from the scenario's WHEN/THEN and either rewrites or deletes a fake block; it creates the `## Test Strategy` section first when absent.
- The Test Requirement block is exactly four fields (ID, File, Command, Pass). The Test Strategy declares runner, full-suite command, and typed prerequisites.
- Constraint (unchanged from the parent change): only the three custom skills, `tests/test_skill_content.sh`, `README.md`, and the main spec (at archive) may change. No upstream OpenSpec step or command file may change.
- `add-validation-linting` is still in progress (0/15) and may renumber the validate skill's top-level steps before this change lands.

## Goals / Non-Goals

**Goals:**
- An opt-in, author-declared full-suite regression gate at validate (step 6c): bounded, declared-only, read-only
- A lowest-genuine-level rule for every Test Requirement block apply-audit generates or rewrites
- Pattern D detection (mocked subject) and its remediation, so unit-level blocks stay genuine
- Full backward compatibility: no `regression: enabled` line → validation identical to today

**Non-Goals:**
- Re-running inherited blocks individually after archive (the regression suite against main specs — deferred by the parent change)
- CI integration — the gate lives at the validate checkpoint, not in a pipeline
- Runner auto-detection — the declaration is the contract
- A fifth block field — level and gate live in Test Strategy; the block stays ID/File/Command/Pass

## Decisions

**D1: The gate is opt-in and author-set**

Suite cost and flakiness vary by project; a forced suite run would make every validation in a slow or flaky project a coin flip at the archive gate. The author — who knows the suite — decides by declaring `regression: enabled` in the Test Strategy. Absent → no step 6c, no row, no finding. Apply-audit never adds the field on its own, even when it must create the Test Strategy section to generate blocks: enabling a gate is a project-level cost decision, not a remediation side effect.

Alternatives considered:
- Always-on gate with the existing full-suite command — rejected: punishes every project with a slow or flaky suite, and validate's cost bound (which D7 keeps predictable) would no longer hold
- Per-block `suite` flag — rejected: the suite is one change-level run, not a per-scenario property

**D2: The suite has its own timeout, separate from the block timeout**

120s is sized for a single test; a full suite is many tests, and forcing it through the block timeout would make the gate unusable for anything real. The suite gets a 600s default, overridable per change by `suite-timeout: <seconds>` in the Test Strategy. A timeout is an Error with partial output — the same shape as a block timeout, so the remediation path (split, speed up, raise the timeout, or disable the gate) is the same human decision at the checkpoint.

**D3: Skips are Info at the suite level, Error at the block level**

A declared block that skips asserts nothing about its declared outcome — the requirement is not satisfied, so Error (existing behavior, unchanged). A suite legitimately carries skips (platform-conditional tests, pending work); failing validation on them would make the gate useless in any real project. Suite skips therefore produce one Info finding with the count — one finding, not one per skip — and the row still reads Pass.

**D4: Pattern D accompanies the level rule**

The level rule pushes generated blocks toward the unit level — which is exactly where mock-only assertions appear (the mocked subject returns canned values, and asserting on them verifies the mock, not the behavior). Patterns A–C do not catch it: the command is runnable, the pass criterion is not existential, and the command is plausibly behavior-related. Without Pattern D, the level rule would increase fake blocks instead of decreasing them. The exception is explicit — mocking only the subject's dependencies is normal unit testing and never triggers D — and the evidence rule (scenario outcome and mocked subject quoted side by side) mirrors Pattern C's discipline, keeping the semantic judgment checkable at the audit checkpoint.

**D5: The gate fields live in Test Strategy, not the block**

The block stays four fields. The gate and its timeout are change-level properties (one suite, one run), so they belong in the Test Strategy that already declares the full-suite command. Both fields are optional; the audit raises one Info when either is malformed (e.g., `suite-timeout: fast`), never an Error — a typo in an optional field is a checkpoint conversation, not a blocker, consistent with the single-Info discipline for Test Strategy issues.

**D6: The level rule is a generation rule, not a block field**

There is no `Level` field; the level is implied by which test the File/Command points to. The rule: outcome produced by a single function or module → unit test; outcome crossing a process, network, or persistence boundary → integration or e2e test. The generated Command SHALL be expected to finish within the 120s per-block timeout — a command that cannot has its scenario split, or is flagged for the human at the audit checkpoint (apply-audit does not silently write a command it knows will time out). The rule applies to both generation branches: missing-block generation and fake-block rewrite.

**D7: Suite placement, category, and reporting**

Step 6c runs after 6b: per-requirement block evidence first, then the project-level backstop — and the suite runs even if blocks failed, so both signals are on the record. Findings use a new Category `Executable: suite` (distinct from `Executable: tests`) with the normal VD- sequence, so regression detection against prior validations keeps working. The Coverage Metrics row is `Full suite | Pass/Fail/Not run`, present only when the gate is enabled: Pass on a clean exit (skips noted as Info), Fail on a non-zero exit or timeout, Not run when the suite did not run for an unmet prerequisite. Gate absent → no row: the report is identical to today's, which is what "validated exactly as today" means. The suite run does not count against the 25-block command cap: it is one opt-in run bounded by its own timeout, and counting it would make the effective cap depend on the gate.

**D8: Malformed gate fields degrade to absent/default at validate**

Validate stays mechanical: a `regression:` value that is not exactly `enabled` is treated as absent (no suite run, no finding — the audit's Info is the correction point), and a malformed `suite-timeout:` falls back to the 600s default, noted in evidence. The semantic "is this malformed?" judgment stays at the audit, not the archive gate.

## Risks / Trade-offs

[Risk] Enabled gate + flaky suite → spurious Fails at the archive gate → **Mitigation**: the gate is opt-in precisely so authors don't enable it on a flaky suite; a Fail is an Error, but the human at the checkpoint decides (re-run, fix, or disable the gate) — consistent with "the human is the controller".

[Risk] Suite cost: up to 600s added to every validation in a project with the gate enabled → **Mitigation**: that is the gate's purpose; the author tunes `suite-timeout` or disables the gate. Re-validation is human-triggered and infrequent.

[Risk] Pattern D is a semantic judgment ("is the subject mocked?") and can misfire → **Mitigation**: mandatory side-by-side evidence, the explicit dependency-mock exception, Warning severity only, human review at the audit checkpoint — the same posture as Pattern C.

[Risk] Level-rule misclassification: an outcome that looks single-module actually crosses a boundary → **Mitigation**: the rule sets a floor ("lowest level that genuinely exercises"), never a ceiling — the author or apply-audit may always target a higher level; the 120s fit check catches commands that are too large for the block they declare.

[Trade-off] `Not run` (gate enabled, prerequisite unmet) is an Error whose suite health is unknown. Accepted: an unmet prerequisite is already an Error for blocks, and the suite inherits the same treatment.

[Trade-off] The suite result is one whole-suite row, not compared block-by-block against 6b's per-test results. Accepted: the gate is a backstop, not a second test plan; per-test attribution is the block's job.

## Test Strategy

```
Runner: bash (plain scripts, no test framework)
Full suite: bash tests/deploy_test.sh && bash tests/test_skill_content.sh
Prerequisites:
  - file: deploy.sh
  - file: tests/deploy_test.sh
  - file: tests/test_skill_content.sh
  - file: skills/openspec-audit-change/SKILL.md
  - file: skills/openspec-apply-audit/SKILL.md
  - file: skills/openspec-validate-change/SKILL.md
regression: enabled
```

The gate is enabled here on purpose: this change's own validation is the first real exercise of step 6c, running the full suite (600s default) alongside the six declared blocks.

## Migration Plan

No migration. The change is additive skill content plus six new test functions. A change with no `regression: enabled` line validates exactly as before (no step 6c, no row, no finding). Rollback is a revert of the three skill files, the harness, and the README line — no persisted state, no format versioning.

## Open Questions

None — the forks (opt-in vs forced gate, separate suite timeout, skip severity, level-rule shape, Pattern D scope, cap interaction) are resolved above.
