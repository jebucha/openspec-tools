# Proposal

## Why

The top-level README now documents a Mixture of Models workflow in which every audit/validate checkpoint ends with the human choosing (fix / re-audit / proceed / stop) and each phase runs in its own fresh session with a role-appropriate model. The completion prompts of the three checkpoint skills — the skills that *are* those checkpoints — predate that rewrite: they present flat option lists in which the documented next step is buried or absent (propose-audit re-audit is never mentioned after apply-audit), and none carry the fresh-session or role framing the README promises. The skills are the runtime expression of the workflow the README documents, and they should match it.

## What Changes

- **Re-order and re-frame the follow-up options in `skills/openspec-audit-change/SKILL.md` (step 12, "Offer follow-up actions")**: present the checkpoint options in the documented order — fix with `/opsx-apply-audit` (any model, fresh session), re-audit in a fresh session with a different model (Model C) for a second opinion, proceed to `/opsx-apply` (if no blocking errors), discuss with `/opsx-explore`. Add the "checkpoint — the user decides" framing. Drop the "Want me to help fix any of these findings?" line (redundant with the apply-audit option and in tension with the skill's read-only guardrail).
- **Re-frame the next-action suggestion in `skills/openspec-apply-audit/SKILL.md` (step 8 and the Output On Completion example)**: the documented next step after applying fixes is the Model C re-audit of the *fixed* artifacts in a fresh session — make that the first suggested action, with `/opsx-apply` as the explicit alternative. The clean-verdict branch (nothing to fix → suggest `/opsx-apply`) is unchanged.
- **Re-order and re-frame the follow-up options in `skills/openspec-validate-change/SKILL.md` (step 13, "Offer follow-up actions")**: fix the findings then re-validate in a fresh session with a model that did not write the code (author/reviewer separation), second-opinion re-validation in a fresh session with a different model, archive (if Pass or Conditional). The Fail-verdict `/opsx-apply` option folds into the fix option, since fixing the findings *is* continuing implementation.
- **Keep `skills/openspec-apply-audit/README.md` accurate**: its "What It Does" flow description gains a matching clause for the changed step 8 next-action suggestion, preserving the README↔SKILL.md accuracy invariant established by the prior change.
- **Out of scope by ownership**: the upstream OpenSpec skills (`explore`, `propose`, `apply`, `archive`, `sync-specs`, `update-change`) exist only in the gitignored `.opencode/` directory and are not part of this repo or its deploy. Their handoff prompts (notably propose → "run `/opsx-apply`") remain as upstream ships them; the propose → audit and apply → validate handoffs stay documented in the README only.

## Capabilities

### New Capabilities

None — this change aligns skill instruction text with already-documented workflow behavior; it introduces no new system behavior.

### Modified Capabilities

None — no spec-level requirements change. Verified by full read of the two related capabilities: `audit-lifecycle` (Pending/Resolved state model, apply-audit selection, regression detection) and `validate-change` (validation dimensions, persistence, verdict, stable IDs) neither specifies the follow-up-prompt behavior this change edits. This change opts out of specs via `skip_specs: true` (skill-text only).

## Impact

- `skills/openspec-audit-change/SKILL.md`: step 12 option list and framing.
- `skills/openspec-apply-audit/SKILL.md`: step 8 next-action bullet and the Output On Completion example's closing line.
- `skills/openspec-validate-change/SKILL.md`: step 13 option list and framing.
- `skills/openspec-apply-audit/README.md`: one-sentence flow-description update.
- No changes to `commands/`, the OpenSpec CLI, any executable behavior, or any upstream skill. No new dependencies.
- Deployment: the three SKILL.md files and the apply-audit README are copied wholesale by `deploy.sh`, so the aligned prompts reach deployed projects on the next `./deploy.sh` run. No forced re-deploy is required for correctness of this repo.
