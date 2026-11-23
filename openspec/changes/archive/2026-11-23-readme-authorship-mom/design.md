# Design

## Context

Docs-only change: three localized additions to the top-level `README.md`, one pre-existing structural fix to the main `docs-consistency` spec, and three drift-guard assertions in `tests/test_skill_content.sh`. See proposal.md for motivation and `specs/docs-consistency/spec.md` for the requirements.

## Goals / Non-Goals

**Goals:**

- Record the waiver for this design artifact: none of the schema's `design.md` conditions apply — no cross-cutting change, no new dependencies, no security/performance/migration complexity, no ambiguity requiring technical decisions before implementation.

**Non-Goals:**

- No design decisions: a docs-only change has none to record. Implementation specifics live in the tasks.

## Decisions

- Waive the full design document. The three README additions are localized prose, and the test assertions reuse the established `has "$ROOT_README" ...` pattern in `tests/test_skill_content.sh` (new `assert_readme_*` functions registered in `ALL_TESTS`). All spec scenarios are docs-only and exempt from Test Requirement blocks (6d), so no Test Strategy section is needed.

## Risks / Trade-offs

- Drift-guard assertions pin exact README phrasing → assertions target stable short phrases, not full sentences, so the prose can be reworded around them without breaking the suite.
