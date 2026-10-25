# Design

## Context

See proposal.md — Why. Current state that shapes this design:

- The validate skill forbids executing tests by guardrail (`skills/openspec-validate-change/SKILL.md`: "Test checks are structural — Don't run tests") and its step 6 checks only that test files *exist*.
- The sibling change `add-validation-linting` (in progress) adds executable linting as a new top-level step 8 to the same skill and explicitly lists "running tests" as a deferred enhancement. This change is that enhancement.
- The audit skill's step 6 is its Validity category (6a ambiguity, 6b task dependencies, 6c naming); its 4b referenced-file existence check scans **design.md and tasks.md only**, not spec files.
- Apply-audit's step 5 organizes remediation by finding category, with a `Warnings → Validity` bucket.
- This repo's product is markdown: skills and commands are instruction files, and its only existing test is `tests/deploy_test.sh` (plain bash, ok/bad assertions, `diff -r` of deployed skills).
- Constraint (non-negotiable): only `skills/openspec-audit-change/SKILL.md`, `skills/openspec-apply-audit/`, `skills/openspec-validate-change/SKILL.md`, their READMEs, and — per user decision — `tests/` may be touched. No upstream OpenSpec step (explore, propose, apply, archive) or command file may change. The convention therefore lives in markdown that upstream steps read and write generically.

## Goals / Non-Goals

**Goals:**
- Make validate's test evidence exit-code-based: run what the author declared, report what the machine observed
- Move semantic judgment ("is this a real test?") from the archive gate to the audit checkpoint
- Keep zero-block changes fully backward compatible
- Practice the convention on this change's own artifacts

**Non-Goals:**
- Runner auto-detection in validate — the declaration *is* the contract (detection is the linting change's pattern, deliberately not reused here)
- Re-running Test Requirement blocks inherited from main specs after archive (a regression suite — future enhancement)
- Modifying the structural check (step 6a) — the lint/test distinction is made by 6b + the audit, not by rewriting 6a
- CLI flags for validate (`--test-cmd` etc.) — the Command field in the block is the override mechanism
- CI integration, new CLI dependencies, or any upstream step/command changes

## Decisions

**D1: Convention shape — block under scenario + Test Strategy section**

A Test Requirement block is a bold-labeled bullet list directly under the `#### Scenario:` it belongs to:

```
**Test Requirement**
- **ID:** T-VALIDATE-CHANGE-001
- **File:** tests/test_skill_content.sh::assert_validate_skill_step_6b
- **Command:** `bash tests/test_skill_content.sh assert_validate_skill_step_6b`
- **Pass:** exit code 0
```

The `## Test Strategy` section in design.md declares runner, full-suite command, and prerequisites once; blocks reference it instead of repeating environment details.

Alternatives considered:
- YAML/front-matter in spec files — rejected: `spec.md` files have strict header parsing; non-header structured content under scenarios is the safe zone, and bullet lists match existing scenario style
- Separate file per change (e.g. `tests.yaml`) — rejected: upstream steps read and write the standard artifact set generically; a sidecar file would sit outside what propose/apply/archive handle
- Table format — rejected: harder to edit inline, inconsistent with scenario formatting

**D2: ID format and stability**

`T-<CAPABILITY-UPPERCASE>-<NNN>`: capability is the spec capability the scenario belongs to (e.g. `validate-change` → `T-VALIDATE-CHANGE-001`), NNN sequential per capability. When a block is amended, its ID is kept — stable IDs are what let regression detection compare across validation runs.

**D3: Typed prerequisites**

Prerequisites in Test Strategy MUST be typed: `env: <VAR>`, `file: <path>`, `cmd: <probe>`. Rationale: "unmet prerequisite" must be reportable *distinctly* from "test failed", which is only possible when the validator can check the prerequisite itself. Prose prerequisites are rejected by convention; if one is encountered anyway, the validator records an Info note ("not machine-checkable") and proceeds to execution.

**D4: Audit step 6d — decision table and severities**

```
For each scenario in the change's spec files:
  behavior-changing? (exempt: docs, config, contract-preserving refactor)
   ├─ exempt ────────────────────────────────→ no finding
   ├─ no block ──────────────────────────────→ Warning (VL-n) "missing test requirement"
   └─ block present:
        complete (4 fields)?  no ────────────→ Warning (VL-n) "incomplete block"
        ID format valid?      no ────────────→ Warning (VL-n) "malformed ID"
        genuine (D5)?         no ────────────→ Warning (VL-n) "not a runtime behavior assertion"
design.md has ## Test Strategy?  no ─────────→ single Info finding
```

- All 6d findings are Warning/Info, never Error: this is the only remaining semantic judgment in the system, and it sits at the advisory, human-reviewed checkpoint. Blocking implementation on a judgment call would recreate the model-gated workflow the project rejects.
- **Metrics row**: "Requirements with executable test requirements | X (Y%)" — X counts requirements where *every* behavior-changing scenario carries a complete, genuine block; Y counts requirements with at least one behavior-changing scenario. A scenario with a fake block contributes to per-scenario Warnings and keeps its requirement out of X.
- **Forward-reference exemption**: block `File` paths and Test Strategy file references are exempt from 4b-style existence checks. Note: 4b scans design.md and tasks.md only, so the exemption is substantive for Test Strategy paths inside design.md and defensive for block paths in spec files (LLM auditors over-scope; the exemption states the intent explicitly).

**D5: Fake-block detection — three patterns + boundary rule**

A block is fake if: (A) its Command is static-only (linter, formatter, type checker, vet, compile check); (B) its Pass criterion is existential (asserts only that a file/test exists); or (C) its Command does not plausibly exercise the scenario's declared outcome.

- Pattern C is the judgment-heavy one and requires an evidence rule: quote the scenario's outcome and the block's Command side by side — the same discipline as the existing 4d duplication check.
- **Boundary rule**: a content assertion (grep/diff) *is* a Test Requirement when it verifies the scenario's declared outcome — for a repo whose product is markdown, content is the observable behavior. This is also what admits compiler-failure scenarios (static tool, behavioral criterion about the tool's output).
- **Apply-audit remediation is dual-branch**: replace the block with a genuine assertion, *or delete it* when the scenario is actually exempt. A generate-only remediation would push exempt scenarios toward more blocks instead of fewer.

**D6: Validate step 6b — pipeline**

```
parse blocks from change spec files + read Test Strategy
  → check typed prerequisites ── fail ──→ Error "prerequisite unmet"
  → file + test ID exist? ── no ────────→ Error (distinct from failure)
  → run Command verbatim (120s, ≤25 total)
       exit 0, no skips ────────────────→ Satisfied
       non-zero exit ───────────────────→ Error (evidence: exit code + last 20 lines)
       any skipped/xfail ───────────────→ Error
scenario without block ─────────────────→ existing structural check (6a), unchanged
zero blocks in change ──────────────────→ structural validation + one Info finding
```

Placement: sub-step 6b between structural coverage (renamed 6a) and task completion (7) — no renumbering cascade, and it sits after step 4's "no git changes → skip" guard, so unimplemented changes never reach it. Guardrail work: line 317 ("Test checks are structural") is replaced by an executable-runs guardrail block (declared-only, read-only wrt codebase, 120s timeout, evidence format, 25-command cap, stable VD- IDs), and the "Non-destructive: Read-only analysis" line in Fluid Workflow Integration is reconciled with it (the validator itself never *modifies* code or artifacts — declared-only execution runs the author's declared contract; the declared command's own side effects are the author's, not the validator's — see Risks).

**D7: Skip detection and Pass authority**

Exit codes do not report skips (pytest exits 0 with skipped tests). The declared **Pass field is authoritative** and is evaluated against the *full* captured output; the report's Evidence column cites exit code + last 20 lines. The default Pass — "exit 0, no skipped tests" — is evaluated with per-runner-family skip markers: pytest (`skipped`/`deselected`), jest (`skipped`), go (`--- SKIP`), cargo (`ignored`). Unrecognized runner → exit code only, noted in evidence.

Alternative considered: per-runner "fail on skip" CLI flags — rejected: not portable; many runners treat skips as passing and no standard flag exists.

**D8: Bounded execution**

Hard 120s timeout per command (timeout → Error with partial output); at most 25 commands per run, prioritized by spec order, remainder summarized as Info. Worst case is 25 × 120s; in practice a change declares a handful of per-test commands. The cap keeps the validate step's cost predictable at the archive gate.

**D9: Dogfood harness**

`tests/test_skill_content.sh`: plain bash, named test functions with single-name dispatch (`bash tests/test_skill_content.sh assert_validate_skill_step_6b`), mirroring `deploy_test.sh`'s ok/bad assertion style. Four functions: `assert_audit_skill_step_6d`, `assert_apply_audit_remediation`, `assert_validate_skill_step_6b`, `assert_validate_skill_guardrails` — each asserts the corresponding skill file carries (or no longer carries) the content this change requires. Content assertions are genuine per D5's boundary rule: this repo's deliverable is the skill markdown. This change's own Test Requirement blocks point at these not-yet-existing functions — its audit is the first exercise of the forward-reference exemption.

**D10: Sequencing with add-validation-linting**

That change inserts a new top-level step 8 into the validate skill; this change inserts sub-step 6b, so there is no renumbering collision. Shared touch zones are the Coverage Metrics table, the guardrails list, and the output examples. Recommendation: let the linting change land first so this one diffs against the renumbered file. If the order inverts, this change's tasks renumber step references to match.

## Risks / Trade-offs

[Risk] An author or apply-audit generates a block pointing at a test that `/opsx-apply` never creates → **Mitigation**: validate reports "missing file or test ID" as an Error *distinct* from a test failure, so the remediation path (finish implementation) is obvious at the checkpoint.

[Risk] Skip-marker heuristics are runner-dependent — a skipped test on an unfamiliar runner could go undetected and a block read as Satisfied → **Mitigation**: the declared Pass field is authoritative (an author can declare an explicit output condition); unrecognized runners degrade to exit-code-only with the limitation noted in evidence; known runner families are documented in the skill.

[Risk] Pattern C (behavior-unrelated command) is a semantic judgment and can produce false positives/negatives → **Mitigation**: mandatory side-by-side evidence (scenario outcome vs Command); Warning severity only; human review at the audit checkpoint — consistent with the workflow's "the human is the controller" principle.

[Risk] 120s timeout too short for heavy single-test runs (e.g. slow integration tests) → **Mitigation**: the Command field is what the author declares; a timeout is an Error with partial output and the human decides at the checkpoint (split the test, or accept). Keeping the timeout a skill constant (not a per-block field) keeps the block format at four fields.

[Risk] A declared Command can itself mutate the codebase or reach the network — declared-only constrains what the validator runs, not what the declared command does, so a mis-declared or LLM-hallucinated command is indistinguishable from a genuine one → **Mitigation**: the declaration is the author's contract and the human at the validate checkpoint can reject a suspicious command before it runs; a pre/post clean-tree check is a possible future enhancement, out of scope here.

[Trade-off] The convention is advisory at audit (Warnings). A human who proceeds past fake/missing blocks gets a validate step whose discrimination is structural only — a lint command that exits 0 would read as Satisfied. This is accepted and documented in the spec: semantic test judgment deliberately does not return to the archive gate.

[Trade-off] Worst-case execution cost is bounded but nonzero (25 × 120s). Accepted: declarations are per-test in practice, and the cap exists precisely to bound the gate.

## Test Strategy

```
Runner: bash (plain scripts, no test framework)
Full suite: bash tests/deploy_test.sh && bash tests/test_skill_content.sh
Prerequisites:
  - file: deploy.sh
  - file: tests/deploy_test.sh
  - file: skills/openspec-audit-change/SKILL.md
  - file: skills/openspec-apply-audit/SKILL.md
  - file: skills/openspec-validate-change/SKILL.md
```

## Migration Plan

No migration. The change is additive skill content plus one new test file. Zero-block changes validate exactly as before (structural checks unchanged, one additional Info finding). Rollback is a revert of the three skill files, their READMEs, and the new test file — no persisted state, no format versioning.

## Open Questions

None material — the four design forks (fake-block severity, tests/ allowlist, typed prerequisites, zero-block Info) were resolved with the user during exploration.
