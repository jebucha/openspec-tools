# https://github.com/jebucha/openspec-tools.git

## 1.1 — 2026-07-09

### Added
- **opsx-apply-audit command + skill** — New command to apply audit findings to change artifacts. Resolves errors, warnings, and recommendations in proposal, design, specs, and tasks before implementation.
- **Audit persistence** — Audit reports are now saved to `openspec/changes/<name>/audits/<timestamp>-<model>.md`. Enables multi-LLM comparison and decoupled workflow (audit and apply-audit no longer require the same session).
- **Feasibility checks** in audit — Design-to-codebase compatibility, dependency/import feasibility, pattern consistency.
- **Coherence checks** in audit — Proposal-to-design scope alignment, spec-to-design consistency, task ordering/buildability, security surface awareness.
- **Multi-environment deploy** — `deploy.sh` auto-detects `.opencode/` and/or `.kiro/` and deploys to the appropriate location(s). Supports `--kiro` and `--opencode` flags to force a single target.
- **skill/openspec-apply-audit/README.md** — Documentation for the apply-audit skill.
- **README.md** — Top-level project documentation.

### Changed
- **deploy.sh** — Now dynamically deploys all commands from `command/` and all skills from `skill/` (no longer hardcoded). Supports Kiro (`.kiro/prompts/` + `.kiro/skills/`) in addition to opencode.
- **openspec-audit-change skill** — Upgraded from 3 audit categories (accuracy, completeness, validity) to 5 (added feasibility, coherence). Now persists reports to file. Version bumped to 1.1.
- **opsx-apply-audit** — Loads audit findings from persisted files first, falls back to session context. Supports selecting from multiple saved audits.

## 1.0 — Initial release
