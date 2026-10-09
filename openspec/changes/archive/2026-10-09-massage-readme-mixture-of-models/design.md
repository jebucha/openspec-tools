# Design

## Context

See proposal.md for motivation. The relevant current state:

- The top-level `README.md` presents the workflow as a single-model, single-session flow: a "Workflow" table (7 steps), a "Quality Gates" subsection, a "Looping Back" subsection (an automatic loop diagram), and a "Typical Session" section (one bash block, one model, one session).
- The tooling already supports a multi-session, multi-model workflow:
  - `/opsx-audit` persists each report to `openspec/changes/<name>/audits/<timestamp>-<model>.md` (model is in the filename).
  - `/opsx-apply-audit` (`skills/openspec-apply-audit/SKILL.md`, step 3) checks persisted audit files **first**, derives each file's state from a `## Resolved` lifecycle header (Pending vs Resolved), prefers Pending audits, and falls back to session context only when no persisted file exists. When multiple Pending audits exist it lists them and lets the user pick one; after applying, it writes the `## Resolved` header into that file, which sequences the next run to the remaining Pending audit.
- `skills/openspec-apply-audit/README.md` (Prerequisites and "What It Does → Locates the Audit Report") still describes the older behavior: an audit "must have been run in the current session" and the command "finds the most recent `/opsx-audit` output from the current session." This contradicts `SKILL.md`.
- `deploy.sh` copies each skill directory wholesale (`cp "$skill_dir"*`), so a skill README edit reaches deployed projects on the next deploy. The top-level `README.md` is the repo's own readme and is not deployed.

Constraints: docs-only change. No edits to `SKILL.md`, `commands/`, the OpenSpec CLI, or any executable behavior. Documentation must stay accurate to actual skill behavior.

## Goals / Non-Goals

**Goals:**
- Make the Mixture of Models workflow the headline "Typical Session" in the top-level README.
- Describe the serial, checkpoint-based flow with the human as the controller at every audit/validate.
- Name the principles the workflow rests on (author/reviewer separation, disk-as-shared-memory, human-in-the-loop, cost gradient).
- Keep a lightweight single-model escape hatch for small, low-risk changes.
- Re-frame "Looping Back" as human-driven checkpoints rather than an automatic loop.
- Correct the stale "current session" wording in `skills/openspec-apply-audit/README.md` to match `SKILL.md`.

**Non-Goals:**
- No changes to skill behavior, commands, or the CLI.
- No new features (e.g., no "merge multiple audits" mode in apply-audit; the existing pick-one + `Resolved` sequencing is sufficient).
- No edits to other skill READMEs or to the `docs-consistency` spec.
- No spec deltas (docs-only; `skip_specs: true`).

## Decisions

**D1 — Serial audits, not parallel.** Model C re-audits the *fixed* artifacts (after apply-audit resolves Model B's findings), not the same pre-fix artifacts Model B saw.
- *Why:* In a parallel arrangement (B and C both audit the identical pre-fix artifacts, then both are applied), C's findings are against a stale state — after B's fixes are applied, some of C's findings are already resolved, so C's report cannot be applied blindly and would need per-finding re-triage. Serial means C sees the current state, so its findings are fresh and directly actionable.
- *Alternative considered:* Parallel second-opinion (comparable findings, explicit "B and C disagree" signal). Rejected on staleness grounds; the disagreement signal is still covered by D2 (the human sees conflicting direction at the apply-audit ambiguity pause).

**D2 — The human is the controller at every checkpoint; no automatic loop.** Each `/opsx-audit` and `/opsx-validate` presents findings and stops; the human chooses the next step (fix / re-audit / proceed / stop). The two-audit shape is the documented *focus*, not a cap — the human may run more cycles or proceed earlier.
- *Why:* "Is this good enough?" is a human judgment, not a model output. An automatic "loop until clean" reads as "keep going until green," which is not always the right advice and removes the operator from the gate.
- *Alternative considered:* Document an automatic audit→fix→re-audit loop until the verdict is clean. Rejected — it implies an unbounded loop and cedes the pass/fail decision to the model.

**D3 — Frame each audit/validate as a checkpoint (decision point), not a pass/fail gate.** The model presents a structured findings summary; the human decides how to proceed.
- *Why:* A "gate" implies the model decides pass/fail. A "checkpoint" makes explicit that the model informs and the human decides. This is the operative mechanism behind D2.

**D4 — Validate with a fresh, non-coder model (Model B or C).** The validator must not be the model that wrote the code.
- *Why:* Author/reviewer separation — the model that wrote the code should not grade it. Model B or C is the natural choice because it already internalized the specs during the audit checkpoints (in a fresh session).
- *Note:* In this flow the *code* is written by the more-economical model at the apply step, not by Model A (Model A wrote the artifacts). The binding constraint is "not the coder," phrased that way so it holds regardless of which model fills the apply slot.

**D5 — Use a "more economical" model for `/opsx-apply`, framed as cost strategy.** The README says a more economical model is a reasonable fit at the apply step, with the justification stated: by then the proposal, design, and tasks are well-defined and audited, so implementation is more mechanical.
- *Why:* "Cheaper" reads as a quality compromise; "more economical" reads as a deliberate cost decision with a stated reason.
- *Alternative considered:* Leave model choice unspecified ("a model suited to mechanical implementation"). Rejected — naming the cost strategy is more actionable and matches the intended pattern; the role-based framing (D6) keeps it portable.

**D6 — A/B/C are roles, not specific model names.** The README labels phases by role (strong author, fresh auditor, second-opinion auditor, more-economical implementer, fresh validator) rather than naming specific models.
- *Why:* Readers map roles to whatever models they have available; naming specific models would date the doc and not port across environments (opencode, Kiro, Claude, Qwen).

**D7 — Prescriptive headline with a lightweight escape hatch.** The Mixture of Models flow *is* the "Typical Session." A short note states that small, low-risk changes may collapse the phases into a single model and session (the current flow).
- *Why:* The pattern is the toolset's differentiator and the persistence design was built for it; burying it in a side section is the current problem. But forcing seven sessions onto a trivial change is wrong, so the escape hatch is explicit.
- *Alternative considered:* Keep the current single-model session as the headline and add Mixture of Models as an optional side section. Rejected — that preserves the under-selling this change exists to fix.

**D8 — The apply-audit README correction is a scoped accuracy fix, separate from the narrative rewrite.** Update only the Prerequisites and "Locates the Audit Report" wording to describe persisted-file-first behavior (check `audits/`, derive Pending/Resolved from the `## Resolved` header, prefer Pending, fall back to session context).
- *Why:* The stale wording contradicts `SKILL.md` and would confuse anyone following the multi-model flow. It is a different file and a different concern (correcting a factual error vs. rewriting the workflow narrative), so it is kept as its own task.
- *Alternative considered:* Leave it and only fix the top-level README. Rejected — the contradiction directly undermines the documented workflow.

## Risks / Trade-offs

- [Heavier flow reads as overkill] Seven sessions vs one may look like ceremony for a small change. → Mitigation: the D7 escape hatch names when the full flow is warranted (high-stakes, unfamiliar codebase, security-sensitive) and when to collapse it.
- ["Human chooses" reads as high-friction/slow] Per-checkpoint human decisions could be seen as a tax. → Mitigation: frame as a feature — the model presents a structured, capped findings summary (the audit already caps at 50 findings, severity-ordered), so each decision is fast; the operator is at the gate by design.
- [Docs drift from skill behavior again] The apply-audit README already drifted once. → Mitigation: D8 corrects the known drift and the new README wording is written to match `SKILL.md` step 3 exactly. (Extending the `docs-consistency` capability to cover workflow-prerequisite accuracy is a possible follow-up, out of scope here.)
- [Lost explicit disagreement signal] Serial audits (D1) forgo the clean "B and C disagree on X" comparison that parallel audits would give. → Accepted trade-off: disagreement still surfaces at the apply-audit ambiguity pause (a fix that conflicts with a prior direction pauses for the user), and serial is more robust overall.
- [Role labels confuse model selection] A/B/C roles may leave readers unsure which concrete model to pick. → Mitigation: D6 keeps them as roles with a one-line "map to your available models" note; no specific model is mandated.

## Migration Plan

Docs-only; no runtime migration.

- Top-level `README.md` is the repo's own readme — not deployed by `deploy.sh`, so editing it has no downstream deploy effect.
- `skills/openspec-apply-audit/README.md` is copied wholesale by `deploy.sh` (`cp "$skill_dir"*`), so the correction reaches deployed projects on the next `./deploy.sh` run. No forced re-deploy is required for correctness of this repo; it simply ships with the next deploy.
- Rollback: `git revert` of the commit(s); no data or state is affected.

## Open Questions

None. Decisions that would change the approach (serial vs parallel, human-controlled vs automatic loop, validate model, cost framing) were resolved with the user during exploration and are captured in D1–D8.
