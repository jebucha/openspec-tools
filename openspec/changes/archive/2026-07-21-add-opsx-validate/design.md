## Context

The current OpenSpec workflow has five stages:
1. `/opsx-propose` — Create change with proposal, design, specs, tasks
2. `/opsx-audit` — Audit artifacts for quality (Model B)
3. `/opsx-apply-audit` — Fix audit findings
4. `/opsx-apply` — Implement tasks (Model A/B/C)
5. `/opsx-archive` — Move completed change to archive

After step 4, there is no validation that the implementation actually satisfies the specs, covers edge cases with tests, or avoids regressions. The user must manually verify quality before archiving. A dedicated validation step, run with an independent model, fills this gap.

## Goals / Non-Goals

**Goals:**
- Provide a `/opsx-validate` command that independently verifies implementation quality
- Validate spec requirements are met by examining the actual code changes
- Check that tests were written to cover the new requirements
- Detect regressions against prior validations (same lifecycle pattern as audits)
- Persist validation reports for historical tracking
- Support running with a different model than the one that implemented

**Non-Goals:**
- Modifying existing commands or skills
- Replacing the archive step (validate runs before archive, but archive is independent)
- Running automated test suites (validate checks that tests exist and are appropriate, not that they pass)
- Enforcing validation as a hard gate on archive

## Decisions

### D1: Validation runs as a skill, not a CLI subcommand
The validation logic is complex (reading code, comparing against specs, checking tests). It lives as an LLM skill (`openspec-validate-change`) invoked by the `/opsx-validate` command, following the same pattern as `openspec-audit-change`.

**Alternatives considered:**
- CLI subcommand: Would require significant openspec CLI changes
- Inline in archive: Couples validation to archiving; user may want to validate without archiving

### D2: Validation report follows audit lifecycle pattern
Reports persist at `openspec/changes/<name>/validations/<timestamp>-<model>.md` with the same supersede/resolved header pattern as audits. This enables:
- Multiple validations with different models
- Historical tracking across validation iterations
- Regression detection against prior validations

**Alternatives considered:**
- Single validation file: No history, no regression detection
- Separate format: Inconsistent with existing patterns

### D3: Validation checks five dimensions
1. **Spec compliance**: Each spec requirement is verified against the actual code
2. **Test coverage**: Tests exist for new requirements and cover edge cases
3. **Task completion**: All tasks from tasks.md are marked complete and verified
4. **Code quality**: Basic checks for obvious issues (unused imports, dead code in changed files)
5. **Regression safety**: Changed files don't break existing functionality patterns

**Alternatives considered:**
- Only spec compliance: Too narrow; tests and tasks are equally important
- Full linting/type-checking: Out of scope; delegate to existing tooling

### D4: Structured findings with stable IDs
Findings use prefix `VD-` (Validation) with severity levels (Error, Warning, Info), matching the audit pattern. This allows findings to be referenced in subsequent validations for regression detection.

### D5: Verdict determines readiness
- "Pass" — No errors, implementation is ready for archive
- "Conditional" — Only warnings/info; proceed with awareness
- "Fail" — Errors exist; implementation has gaps

## Risks / Trade-offs

- **LLM hallucination on code analysis** → The validating model may misread code. Mitigation: Require evidence (file paths, line numbers) for every finding; user can review.
- **False negatives** → Validation may miss real issues. Mitigation: Validation is advisory, not a hard gate; user judgment still required.
- **Performance on large changes** → Reading many files for large changes is slow. Mitigation: Scope validation to files touched by the change + their immediate dependencies.
- **Model bias** → Same model that implemented may validate its own work leniently. Mitigation: Encourage using a different model; report includes model identifier for transparency.

## Open Questions

- Should validation integrate with the archive command to show validation status during archive? (Deferred — can be added later)
- Should failed validation produce auto-fix suggestions? (Deferred — scope to reporting only for v1)
