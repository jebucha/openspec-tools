# Proposal

## Why

The top-level README documents a single-model, single-session workflow ("Typical Session"), but the toolset's infrastructure was built for a multi-session, multi-model workflow: audit reports persist to `audits/<timestamp>-<model>.md` specifically to enable multi-model comparison and session-decoupled use, and `/opsx-apply-audit` reads persisted audit files first, falling back to session context only when none exist. The README therefore under-sells the toolset's core differentiator — a Mixture of Models workflow where different models (and fresh contexts) are assigned to each phase according to where judgment is needed.

## What Changes

- **Rewrite the top-level `README.md` "Typical Session" as the Mixture of Models workflow**, with each phase in its own fresh session:
  1. **Model A (strong)** — `/opsx-explore` + `/opsx-propose`. The author of the artifacts.
  2. **Model B (fresh session)** — `/opsx-audit`. Presents findings; **the human chooses the next step** (fix / re-audit / proceed / stop).
  3. **Any model** — `/opsx-apply-audit`. Resolves the presented findings. The `## Resolved` lifecycle header written into each audit file sequences multiple audits automatically (the next run picks the remaining pending audit).
  4. **Model C (fresh session)** — `/opsx-audit` again on the *fixed* artifacts (serial, not parallel — the re-audit sees current state, so its findings are fresh and actionable). Presents findings; the human chooses again.
  5. **More economical model** — `/opsx-apply`. Justified by cost strategy, not corner-cutting: the proposal, design, and tasks are now well-defined and audited, so implementation is more mechanical.
  6. **Model B or C (fresh, and not the model that wrote the code)** — `/opsx-validate`. Presents findings; the human chooses (fix / re-validate / archive).
  7. **Any model** — `/opsx-archive`.
- **Name the principles the workflow rests on**: author/reviewer separation (a model does not grade its own artifacts or code); the change directory on disk is the shared memory between sessions (sessions are disposable); the human is the controller at every audit/validate checkpoint — models present findings, humans decide; a cost gradient (expensive models where judgment is required, more economical models where work is mechanical).
- **Frame the two-audit shape as the focus, not a restriction** — the human may run additional audit/fix cycles or proceed earlier; the doc describes the shape of the workflow, not a quota.
- **Keep a lightweight escape hatch**: for small, low-risk changes, phases may collapse into a single model and session (the current flow).
- **Update the "Looping Back" section** to match the checkpoint framing: iteration is driven by the human's choice at each audit/validate, not by an automatic loop-until-clean.
- **Fix stale wording in `skills/openspec-apply-audit/README.md`**: the Prerequisites and "What It Does" sections state that an audit "must have been run in the current session" and that the command "finds the most recent `/opsx-audit` output from the current session." The actual skill (`SKILL.md`) checks persisted audit files in `audits/` first and uses session context only as a fallback. Correct the README to match the persisted-file-first behavior, so the documented workflow and the skill's documented prerequisites agree.

## Capabilities

### New Capabilities

None — this change documents an existing, already-supported workflow; it introduces no new system behavior.

### Modified Capabilities

None — no spec-level requirements change. The `docs-consistency` capability (paths and deployment sections) is not affected: the apply-audit README fix corrects workflow-prerequisite wording, not paths or deployment sections. This change opts out of specs via `skip_specs: true` (docs-only).

## Impact

- `README.md` (top-level): Workflow overview, "Typical Session", and "Looping Back" sections.
- `skills/openspec-apply-audit/README.md`: Prerequisites and "What It Does" → "Locates the Audit Report" wording (accuracy fix, no behavior change).
- No changes to `SKILL.md` files, `commands/`, the OpenSpec CLI, or any executable behavior. No new dependencies.
