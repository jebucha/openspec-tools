# Design

## Context

See proposal.md for motivation. The relevant current state:

- The top-level `README.md` (rewritten by the prior change `massage-readme-mixture-of-models`) documents the Mixture of Models workflow: seven phases in fresh sessions, role labels A/B/C (strong author / fresh auditor / second-opinion auditor / more-economical implementer / fresh validator), an explicit human decision ("you choose: fix / re-audit / proceed / stop") at every audit and validate checkpoint, a "Quality Checkpoints" section, and a lightweight escape hatch for small changes.
- The three checkpoint skills — the user-owned, git-tracked skills in `skills/` that `deploy.sh` ships — end with flat follow-up option lists that predate that rewrite:
  - `skills/openspec-audit-change/SKILL.md` step 12: five flat options; the re-audit option is last and phrased "to compare findings"; a "Want me to help fix any of these findings?" line sits first despite the skill's read-only guardrail.
  - `skills/openspec-apply-audit/SKILL.md` step 8 and Output On Completion: suggest only "Run `/opsx-apply` to start implementing" — the documented Model C re-audit of the fixed artifacts is never mentioned.
  - `skills/openspec-validate-change/SKILL.md` step 13: four flat options; re-validation is phrased "to compare"; the "Want me to help fix" line has the validator offering to fix code it just reviewed; a separate Fail-verdict `/opsx-apply` option duplicates the fix path.
- The upstream OpenSpec skills (`explore`, `propose`, `apply`, `archive`, `sync-specs`, `update-change`) exist only in the gitignored `.opencode/skills/` directory — local CLI installs, not part of this repo, not deployed by `deploy.sh`. Their handoff prompts are upstream's to change.
- `skills/openspec-apply-audit/README.md` describes the skill's flow and was just made meticulously accurate to `SKILL.md` by the prior change; that README↔SKILL.md accuracy invariant must be preserved.

Constraints: skill-instruction-text only. No changes to skill behavior beyond the closing prompts (steps, guardrails, report formats, persistence all unchanged). No spec deltas (`skip_specs: true`). No changes to upstream skills, `commands/`, or the CLI.

## Goals / Non-Goals

**Goals:**
- Each checkpoint skill's closing prompt presents the documented next step first, in the README's order, with fresh-session and role framing.
- Use the README's own vocabulary: "checkpoint", "fresh session", "second opinion", "Model C", "a model that did not write the code".
- Preserve the apply-audit README↔SKILL.md accuracy invariant.

**Non-Goals:**
- No changes to upstream OpenSpec skills — the propose → audit and apply → validate handoffs remain documented in the README only.
- No new prompt mechanism: no `AskUserQuestion` enforcement, no structured checkpoint UI, no blocking gates. The prompts remain advisory option lists; the human is the controller.
- No changes to skill steps, guardrails, report structure, or file persistence.
- No spec deltas.

## Decisions

**D1 — Light touch: re-order plus one line of session/role language, not a rewrite into explicit checkpoint blocks.**
- *Why:* Minimal diff, keeps each skill's existing list format and tone. The user chose this over a full checkpoint-block rewrite ("You are at a checkpoint. Options: 1… 2… 3…") during exploration.
- *Alternative considered:* Rewrite each ending as a structured checkpoint block. Rejected — more words on every run, larger diff, and it changes the skills' output style beyond what this change is about.

**D2 — Documented path first, alternatives after.** The option order in each skill mirrors the README's Typical Session table:
- audit: fix (`/opsx-apply-audit`) → re-audit (fresh session, Model C) → proceed (`/opsx-apply`, if no blocking errors) → discuss (`/opsx-explore`)
- apply-audit: re-audit the fixed artifacts (fresh session, Model C) → proceed (`/opsx-apply`)
- validate: fix then re-validate (fresh session, non-coder model) → second-opinion re-validation (fresh session, different model) → archive (if Pass or Conditional)
- *Why:* The README's Typical Session table is the canonical order; the prompt should nudge toward the documented shape while keeping it a nudge — every alternative stays available, consistent with "the two-audit shape is the documented focus, not a quota".
- *Alternative considered:* Keep the current order and only add session language. Rejected — the whole point is that the documented path is currently buried or absent; re-ordering is the core of the fix.

**D3 — Session/role wording: "fresh session" + role labels, no environment-specific "clear context" phrasing.**
- *Why:* These skills deploy to opencode, Kiro, Claude, and Qwen via `deploy.sh`. "Clear context" is opencode-specific mechanics; "fresh session" plus a role label (Model C, "a model that did not write the code") is portable and matches the README's role-based framing (its decision D6: roles, not specific model names).
- *Alternative considered:* Environment-specific session language. Rejected — not portable across the four deploy targets. Omitting session language entirely was also rejected — the fresh-session handoff is the core of the MoM promise the README makes.

**D4 — Drop the "Want me to help fix any of these findings?" line from the audit and validate skills.**
- *Why:* Both skills are read-only by guardrail; offering to fix directly contradicts that. In validate the issue is sharper: a validator that then fixes the code becomes the coder, violating author/reviewer separation — the README's decision D4 exists precisely so "the model that wrote the code should not grade it". The fix option is rephrased to carry the constraint: "Fix the findings, then re-run `/opsx-validate` in a fresh session with a model that did not write the code."
- *Alternative considered:* Keep the line and interpret it as "via `/opsx-apply-audit`". Rejected — ambiguous, and the apply-audit option is already in the list.

**D5 — Fold the Fail-verdict `/opsx-apply` option into the validate fix option.**
- *Why:* On a Fail verdict, "fix the findings" *is* continuing implementation; a separate "Run `/opsx-apply` to continue implementing (if Fail verdict)" option implied either re-running apply without fixing or a path from Fail to archive, neither of which makes sense.
- *Alternative considered:* Keep all four current options. Rejected — the redundancy muddies the checkpoint.

**D6 — The apply-audit README keeps a one-sentence clause matching the changed step 8.**
- *Why:* The prior change established that the apply-audit README's flow description must match `SKILL.md`. Step 8's next-action wording is changing, so the README's description of what the skill does at the end must follow.
- *Alternative considered:* Leave the README untouched. Rejected — it would recreate exactly the docs drift this toolset just spent a change fixing.

**D7 — The clean-verdict branch is unchanged.** `skills/openspec-apply-audit/SKILL.md` line 64 ("If the selected audit verdict is clean … suggest proceeding with `/opsx-apply`") stays as-is.
- *Why:* When the audit is clean there is nothing to fix, so a re-audit adds nothing; suggesting `/opsx-apply` is the correct next step in that branch.

## Risks / Trade-offs

- [Prompt wording drifts from the README again] → Mitigation: the new wording reuses the README's exact vocabulary (checkpoint, fresh session, second opinion, Model C), and a cross-file consistency task verifies no statement in a skill's closing prompt is contradicted by the README's Typical Session table or Quality Checkpoints section.
- [The propose → audit gap remains visible at runtime] → Accepted trade-off: that prompt lives in an upstream-owned, gitignored skill. The README documents the flow, the escape hatch legitimizes the collapsed path for small changes, and once the user reaches `/opsx-audit` a user-owned skill takes over with the aligned checkpoint.
- ["Model C" after apply-audit reads oddly to someone who skipped the first re-audit] → Mitigation: the README's Typical Session table assigns Model C to session 4 (re-audit after apply-audit), so the label is consistent with the documented flow; the option text says "a different model" as well, so the role label is decorative, not load-bearing.
- [Deployed projects keep the old prompts until re-deploy] → Mitigation: same as the prior change — `deploy.sh` copies skill directories wholesale, so the aligned prompts ship on the next `./deploy.sh` run; no forced re-deploy is required for correctness of this repo.

## Migration Plan

Skill-instruction-text only; no runtime migration.

- The three SKILL.md files and the apply-audit README are copied wholesale by `deploy.sh` (`cp "$skill_dir"*`), so the aligned prompts reach deployed projects on the next deploy. No forced re-deploy required.
- Rollback: `git revert` of the commit(s); no state is affected.

## Open Questions

None. The prompt shape (light touch), vocabulary (README's own terms), and scope (user-owned skills only) were resolved with the user during exploration and are captured in D1–D7.
