# Proposal

## Why

The top-level `README.md` never names the developer: attribution currently lives only in the `LICENSE` ("Copyright (c) 2026 JB") and in the skill frontmatter (`author: jebucha`). A first-time reader can reasonably mistake this repo for an official OpenSpec artifact. Separately, the README documents *how* the audit and validate checkpoints use a Mixture of Models (fresh sessions, Model B/C roles, per-model report files) but never states *why that matters* — that different model families have different blind spots, so cross-model audit/validation catches issues a single model consistently misses.

## What Changes

- Add an authorship statement to the README introduction: the work is developed by JB (jebucha) and is an independent toolset that extends the OpenSpec workflow — not an official OpenSpec artifact.
- Add a short "why Mixture of Models matters" statement in the Principles / Quality Checkpoints area, naming the multi-model diversity benefit as the reason audit (step 3) and validate (step 6) are run by models that did not write what they review.
- Add a context-isolation statement in the Quality Checkpoints area: switching to the auditor or validator role starts a session with cleared context — no authoring conversation carries over, and the persisted change artifacts (proposal, design, specs, tasks) are the state the new model inherits. The statement must not claim the four artifacts are the auditor's exclusive input (feasibility checks also read referenced source files).
- Fix a pre-existing structural issue in the main spec `openspec/specs/docs-consistency/spec.md` (insert a `## Requirements` section header): the two existing requirements sit outside any `## Requirements` section, so `openspec list --specs` reports 0 requirements and archive would refuse the delta sync.
- No changes to commands, skills, deployment scripts, or the per-skill READMEs.

## Capabilities

### New Capabilities

(none)

### Modified Capabilities

- `docs-consistency`: three new requirements for the top-level `README.md` — (1) it attributes the work to its developer and presents it as an independent extension of OpenSpec; (2) it states why the Mixture of Models approach matters for the audit and validate checkpoints, not just how it is run; (3) it documents that switching to the auditor/validator role starts a session with cleared context, inheriting the persisted change artifacts — not the authoring conversation.

## Impact

- `README.md` — three localized additions (intro authorship line; Mixture of Models importance statement near Principles/Quality Checkpoints; context-isolation statement in Quality Checkpoints).
- `openspec/specs/docs-consistency/spec.md` — gains three new requirements with scenarios at archive sync (authored in the change delta `specs/docs-consistency/spec.md`).
- `openspec/specs/docs-consistency/spec.md` (main spec) — pre-existing structural fix required before archive sync: the two existing requirements sit outside a `## Requirements` section.
- No code, command, skill, or deployment-script changes; `tests/test_skill_content.sh` assertions for README documentation gain three checks to keep the drift guard consistent.
