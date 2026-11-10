# Proposal

## Why

The executable-test-requirements feature (change `add-executable-test-requirements`, archived 2026-10-25) shipped new behavior across three skills — validate now *runs* declared test commands and judges readiness by exit-code evidence rather than model judgment — but the top-level `README.md` was not updated with it. A reader following the README has no way to learn the Test Requirement block convention or the `## Test Strategy` section, so proposed changes will ship with zero executable test requirements and users will receive findings they cannot decode.

## What Changes

All changes are to the top-level `README.md` only:

- **New "Executable Test Requirements" section** — documents the block convention (ID/File/Command/Pass under a spec scenario), the `## Test Strategy` section in design.md (runner, full-suite command, typed prerequisites), exemptions (docs, config, contract-preserving refactor), what is *not* a genuine block (static-only commands, existential pass criteria, behavior-unrelated commands; content assertions such as grep/diff *are* genuine), a worked example reusing the existing `add-data-export` sample identity, the new `Executable tests passed` metric row and `Executable: tests` finding category, and the evidence-over-attestation payoff.
- **Validation Dimensions table** — the Test coverage row is reworked to describe both checks: execution of declared Test Requirement blocks (6b) and the structural coverage check (6a) for scenarios without blocks; skipped tests are errors.
- **Executable-runs guardrails note** — validate now runs commands; the README must say how bounded that is: declared-only execution (verbatim, never synthesized or broadened), no dependency installs or environment edits, 120-second timeout per command, 25-command cap per validation, findings cite exit code plus last 20 lines of output.
- **Audit Categories table** — the Validity row gains: behavior-changing scenarios carry genuine Test Requirement blocks (audit step 6d).
- **Validate checkpoint bullet** — notes execution of declared test requirements.
- **apply-audit rows** (workflow table + Skills table) — notes it generates missing Test Requirement blocks and creates the Test Strategy section when remediating.
- **Project Structure tree** — adds the `tests/` entry (`tests/test_skill_content.sh`).
- **Typical Session** — Session 1 note that the proposal carries Test Requirement blocks and a Test Strategy, making Session 6's verdict evidence-based.

Non-goals: no edits to skill files, skill READMEs, commands, or other docs; no changes to the in-flight `add-validation-linting` change (a second, small README pass is expected when linting lands).

## Capabilities

### New Capabilities

None.

### Modified Capabilities

None — this is a documentation-only change. `skip_specs: true` is set in `.openspec.yaml`, consistent with prior README changes (`update-workflow-docs`, `align-checkpoint-prompts`, `massage-readme-mixture-of-models`).

## Impact

- `README.md` — all eight edits listed above
- No code, skill, command, or spec changes
- The per-skill READMEs were updated in the same commit that shipped the feature and are already consistent; only the top-level README drifted
