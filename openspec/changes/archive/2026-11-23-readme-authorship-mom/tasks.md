# Tasks

## 1. Fix docs-consistency main spec structure (pre-existing blocker)

- [x] 1.1 Insert a `## Requirements` section header before the first `### Requirement:` in `openspec/specs/docs-consistency/spec.md` (the main spec's two requirements currently sit directly under the capability header, outside any `## Requirements` section, so `openspec list --specs` reports 0 requirements and archive would refuse the delta sync); keep the capability header, purpose line, and both existing requirement blocks unchanged; verify `openspec validate "readme-authorship-mom"` no longer reports "target spec is structurally invalid" and `openspec list --specs --json` shows requirementCount 2 for `docs-consistency`

## 2. README authorship attribution

- [x] 2.1 Add an authorship statement to the top-level `README.md` introduction (currently line 3) stating the toolset is developed by JB (jebucha) and is an independent project extending the OpenSpec workflow, not an official OpenSpec artifact; verify by re-reading the introduction and confirming the statement names both forms of the author name ("JB (jebucha)"), so it agrees with the `LICENSE` copyright holder ("JB") and the skill frontmatter `author: jebucha`, each matching one form
- [x] 2.2 Add a new `assert_readme_authorship` function in `tests/test_skill_content.sh` using the existing `has "$ROOT_README" ...` pattern, asserting the `jebucha` attribution, the "independent project extending the OpenSpec workflow" clause, and the "not an official OpenSpec artifact" clause are all present; register the function in `ALL_TESTS` (an unregistered function is never run) and run the full suite (`bash tests/test_skill_content.sh`) to verify all new assertions pass

## 3. README Mixture of Models importance

- [x] 3.1 Add a Mixture of Models importance statement to the top-level `README.md` in the Principles or Quality Checkpoints area (not only in the Typical Session section): different models have different blind spots, so cross-model review at the audit (step 3) and validate (step 6) checkpoints catches issues a single model's self-review would miss; verify by re-reading the section and confirming the statement names both the audit and validate checkpoints and does not rely on the Typical Session section for its rationale
- [x] 3.2 Add a new `assert_readme_mom_rationale` function in `tests/test_skill_content.sh` using the existing `has "$ROOT_README" ...` pattern, asserting the blind-spots rationale phrase is present and the statement names the audit and validate checkpoints; register the function in `ALL_TESTS` (an unregistered function is never run) and run the full suite (`bash tests/test_skill_content.sh`) to verify all new assertions pass

## 4. README context isolation at model switches

- [x] 4.1 Add a context-isolation statement to the top-level `README.md` Quality Checkpoints section (the audit and validate checkpoint bullets): switching to the auditor or validator role starts a session with cleared context — the model brings no conversational context from the authoring session, and the persisted change artifacts (proposal, design, specs, tasks) are the state it inherits; do NOT claim the four artifacts are the auditor's exclusive input (feasibility checks also read referenced source files); verify by re-reading the section and confirming the statement covers both the audit and validate checkpoints and does not contradict the audit skill's feasibility source-file reads
- [x] 4.2 Add a new `assert_readme_context_isolation` function in `tests/test_skill_content.sh` using the existing `has "$ROOT_README" ...` pattern, asserting the cleared-context statement is present and the no-overclaim clause (feasibility checks also read referenced source files) is present; register the function in `ALL_TESTS` (an unregistered function is never run) and run the full suite (`bash tests/test_skill_content.sh`) to verify all new assertions pass

## Workflow follow-up

- On archive, sync the `docs-consistency` delta into `openspec/specs/docs-consistency/spec.md` (the three new requirements land there via spec sync).
