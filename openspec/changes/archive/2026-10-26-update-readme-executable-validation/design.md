# Design

## Context

See proposal.md for motivation. The relevant current state:

- `README.md` describes validation as pure inspection: the Validation Dimensions table says Test coverage checks "Do tests exist for new requirements and edge cases?" and nothing in the README mentions running commands, Test Requirement blocks, Test Strategy sections, the new metric row, or the new finding category.
- The shipped truth lives in three skill files, all updated in the same commit (`b1a17d1`):
  - `skills/openspec-audit-change/SKILL.md` (v1.3) — step 6d: presence/genuineness checks, forward-reference exemption, "Requirements with executable test requirements" coverage row.
  - `skills/openspec-apply-audit/SKILL.md` (v1.1) — remediation of 6d findings: generate missing blocks, replace/delete fake blocks, create Test Strategy before blocks.
  - `skills/openspec-validate-change/SKILL.md` (v1.1) — step 6a (structural, unchanged, applies only to unblocked scenarios) and step 6b (parse blocks + Test Strategy, check typed prerequisites, verify file/test ID, execute verbatim, classify by Pass criterion), guardrails (declared-only, no mutation, 120s timeout, 25-command cap), metric row "Executable tests passed", category "Executable: tests".
- The per-skill READMEs were updated in the same commit and are already accurate; only the top-level README drifted.
- The `executable-test-requirements` spec (archived change `add-executable-test-requirements`) is the normative source for the convention: block format `T-<CAPABILITY-UPPERCASE>-<NNN>` / File (`path::test_id`) / Command / Pass; Test Strategy prerequisites typed `env:` / `file:` / `cmd:`; fake-block patterns (static-only, existential, behavior-unrelated); content-assertion boundary rule; exemptions (docs, config, contract-preserving refactor).
- `tests/test_skill_content.sh` exists at the repo root (content guards for the skills) but the Project Structure tree does not show `tests/`.

Constraints: docs-only change to `README.md`. No edits to skills, commands, or other docs. The README must stay accurate to the skill files — when wording can be mirrored, it is.

## Goals / Non-Goals

**Goals:**
- Give a README reader everything needed to *author* a change that will pass the executable-validation checks: the block convention, Test Strategy section, exemptions, and fake-block rules.
- Tell a README reader that `/opsx-validate` now *runs* declared commands, with the boundary conditions (declared-only, no mutation, timeout, cap, exit-code evidence).
- Keep the README a summary layer: document the contract and the guardrails, point to skill READMEs for pipeline detail, never duplicate step-by-step logic.
- Preserve the README's existing structure, table style, and section ordering; edits are additions and in-place rewrites, not a reorganization.

**Non-Goals:**
- No mention of the in-flight `add-validation-linting` change (unshipped; a second small README pass is expected when it lands).
- No changes to the four Principles, the workflow diagram, or the Typical Session bash script.
- No edits to skill files, skill READMEs, commands, or the `docs-consistency` spec.
- No spec deltas (docs-only; `skip_specs: true`).

## Decisions

**D1 — One new top-level section, "Executable Test Requirements," placed after Validation Dimensions and before Audit Persistence.**
- *Why:* The convention is cross-skill (authored at propose, checked at audit, remediated at apply-audit, executed at validate) — it is not owned by one step, so a per-section mention in each of those would fragment it. Placement after Validation Dimensions lets the new section explain the rows the table just introduced (test coverage split, new metric, new category); placement before Audit Persistence keeps the two "persistence/report" sections adjacent.
- *Alternative considered:* Fold the convention into the Validation Dimensions section as a subsection. Rejected — the authoring convention (what to write in spec files and design.md) is not a validation dimension; validate is only the consumer that gives it teeth.

**D2 — Present Test coverage as two named checks (structural 6a / executable 6b), mirroring skill terminology, with the skipped-test-is-error rule stated once.**
- *Why:* The skill split the check into 6a/6b; using the same names in the README keeps the two documents mutually decodable. "A skipped test asserts nothing, so the requirement is not satisfied" is the rule readers will most want to know before trusting a Fail verdict, so it gets a sentence rather than living only in the skill file.
- *Alternative considered:* Restate the full 6b pipeline (parse → prerequisites → existence → execute → classify) in the README. Rejected — that duplicates the skill and will drift; the README says *what happens* (declared tests are run; failures, skips, missing files, unmet prerequisites are Errors with exit-code evidence) and *stops*.

**D3 — Guardrails as a short bullet list inside the new section, not a section of their own.**
- *Why:* The four guardrail properties (declared-only, no mutation/installs, 120s timeout, 25-command cap) are boundary conditions of one behavior, not a workflow concept; a standalone section would over-weight them. Four bullets after the convention description is enough for a reader to judge trust in a verdict.
- *Alternative considered:* A "Security notes" framing emphasizing that the validator runs project commands. Rejected — the commands come from the user's own spec files, in the user's own project, under explicit guardrails; security framing would imply a risk the design already closed.

**D4 — Do not add "evidence over attestation" to the Principles list.**
- *Why:* The existing four principles describe the *shape of the workflow* (separation of roles, persistence, human control, cost). The evidence shift is a method change inside one skill. Stating it in the new section ("validation is judged by exit-code evidence, not model judgment") carries the message where the reader needs it without diluting the principle list.
- *Alternative considered:* Fifth principle. Rejected — it mixes levels of abstraction with the other four.

**D5 — The worked example reuses the README's existing sample change (`add-data-export`, `T-CSV-EXPORT-001`, `tests/export.test.ts`).**
- *Why:* The validate skill's example output already uses this ID family and change name; reusing it means a reader who hits a real `T-CSV-EXPORT-001` finding in a validate report sees the same object documented. It also avoids inventing a fourth example identity in a doc that already carries `add-user-auth`.

**D6 — Table edits are in-place cell rewrites, keeping row counts and column shape.**
- *Why:* Rewriting a cell in place preserves each table's line shape (row/column counts, which task 4.4 verifies) and is the smallest diff that restores accuracy. The apply-audit one-clause additions (workflow table row 16, Skills table row 85) follow the same rule.

**D7 — Project Structure tree gains a single `tests/` entry with `test_skill_content.sh`.**
- *Why:* The tree is the repo's self-description and the file is load-bearing (it is the Test Requirement for the feature itself). Placement follows the tree's existing alphabetical-ish grouping, after the `openspec/` entry and before `deploy.sh`.

**D8 — Typical Session gets a one-clause note in the Session 1 row, not a new session.**
- *Why:* Block authoring happens inside `/opsx-propose` (Session 1); the session count and model assignments do not change. One clause in the "What happens" cell ("...proposal, design, and tasks — including Test Requirement blocks and a Test Strategy, so the later validate verdict is evidence-based") is the whole edit.

## Risks / Trade-offs

- [README wording drifts from skill files on a future skill change] → Mitigation: mirror skill wording verbatim for the four field names, the ID format, the three prerequisite types, the three fake-block patterns, and the four guardrail properties; the consistency check is a grep-level review at apply time, not a formal test.
- [The linting change (`add-validation-linting`) rewrites the Validation Dimensions table again] → Accepted by design (see Non-Goals): this change documents only shipped behavior; a second small pass is cheaper than holding a true change hostage to an unshipped one.
- [New section grows the README past its summary role] → Mitigation: D1/D2/D3 bound the section to convention + guardrails, ~25 lines; pipeline detail stays in `skills/openspec-validate-change/README.md`.
- [Reader mistakes "content assertions are Test Requirements" for "any shell command counts"] → Mitigation: the section states both halves together — the boundary rule (grep/diff of a declared outcome *is* genuine) immediately after the fake-block patterns, matching the spec's ordering.
