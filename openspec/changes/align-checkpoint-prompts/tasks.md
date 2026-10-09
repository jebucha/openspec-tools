# Tasks

## 1. Audit skill — checkpoint prompt

- [x] 1.1 Rewrite step 12 ("Offer follow-up actions") in `skills/openspec-audit-change/SKILL.md`: present the options in the documented order — fix with `/opsx-apply-audit` (any model, fresh session), re-audit in a fresh session with a different model (Model C) for a second opinion, proceed to `/opsx-apply` (if no blocking errors), discuss with `/opsx-explore` — under a "checkpoint — the user decides" framing, and drop the "Want me to help fix any of these findings?" line. Verify: step 12 lists exactly those four options in that order, the re-audit option contains "fresh session" and "Model C", and no "Want me to help fix" line remains in the file.

## 2. Apply-audit skill — checkpoint prompt and README

- [x] 2.1 Update the step 8 next-action bullet in `skills/openspec-apply-audit/SKILL.md` to suggest, under a "checkpoint — the user decides" framing, first the Model C re-audit of the fixed artifacts in a fresh session (`/opsx-audit`), then proceeding to implementation (`/opsx-apply`) as the alternative. Verify: step 8 presents the re-audit before `/opsx-apply`, and the clean-verdict branch ("If the selected audit verdict is clean … suggest proceeding with `/opsx-apply`") is unchanged.
- [x] 2.2 Update the closing line of the Output On Completion example in `skills/openspec-apply-audit/SKILL.md` to match step 8 (re-audit in a fresh session with a different model, or proceed to `/opsx-apply`). Verify: the example's closing line offers the re-audit first and no longer ends with a bare "Run `/opsx-apply` to start implementing."
- [x] 2.3 Add a one-sentence clause to the "What It Does" flow description in `skills/openspec-apply-audit/README.md` matching the changed step 8 next-action suggestion. Verify: the README's description of the skill's closing behavior matches `SKILL.md` step 8 with no contradiction.

## 3. Validate skill — checkpoint prompt

- [x] 3.1 Rewrite step 13 ("Offer follow-up actions") in `skills/openspec-validate-change/SKILL.md`: present the options in the documented order — fix the findings then re-run `/opsx-validate` in a fresh session with a model that did not write the code, second-opinion re-validation in a fresh session with a different model, archive (if Pass or Conditional verdict) — under a "checkpoint — the user decides" framing, and fold the Fail-verdict `/opsx-apply` option into the fix option. Verify: step 13 lists exactly those three options in that order, the fix option names "a model that did not write the code", and no standalone `/opsx-apply` option remains in the list.

## 4. Cross-file consistency

- [x] 4.1 Cross-check the three skills' closing prompts against the top-level `README.md` Typical Session table and Quality Checkpoints section for contradictions (session order, role labels, checkpoint options). Verify: a read of all four files shows no statement in a skill's closing prompt contradicted by the README (in particular, Model C is the re-auditor after apply-audit, and the validator is "not the coder").
- [x] 4.2 Confirm no stale prompt wording survives elsewhere in the repo. Verify: a grep for "Want me to help fix any of these findings" and "to compare" across `skills/` and `.opencode/skills/` returns no hits in the three user-owned skills (upstream skills in `.opencode/skills/` are out of scope and may still contain their own wording).

## Workflow follow-up

- Archive the change after the prompt edits are reviewed and the cross-file consistency check (4.1) passes — ideally through the very flow this change documents: audit → apply-audit → re-audit → apply → validate → archive.
- Note that the aligned prompts ship to deployed projects on the next `./deploy.sh` run (no forced re-deploy required).
