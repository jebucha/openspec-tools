# https://github.com/jebucha/openspec-tools.git

## 1.2 — 2026-07-09

### Added
- **Duplication detection** (Accuracy 4d) — Identifies near-duplicate requirements and scenarios across spec files; flags lower-quality phrasing for consolidation.
- **Terminology drift detection** (Accuracy 4e) — Tracks domain terms across all artifacts; flags when the same concept is named differently in different files.
- **Ambiguity detection** (Validity 6a, enhanced) — Now explicitly flags vague qualifiers ("fast", "scalable", "robust", etc.) and unresolved placeholders (TODO, TBD, TKTK, ???).
- **Coverage metrics table** — Audit output now includes quantitative metrics: total requirements, total tasks, coverage percentages, duplication count, ambiguity count.
- **Stable finding IDs** — Each finding gets a deterministic ID (AC-1, CM-1, VL-1, FS-1, CO-1) for cross-referencing between audit and apply-audit.
- **Findings cap** — Maximum 50 findings per audit, prioritized by severity, with overflow summary.
- **Tabular report format** — Findings presented in a structured table (ID, Category, Severity, Description, Evidence) for easier scanning and reference.
- **Requirements coverage mapping** — Systematic bidirectional mapping of requirements ↔ tasks with gap detection.

### Changed
- **openspec-audit-change skill** — Version bumped to 1.2. Enhanced with 4 new detection capabilities.
- **openspec-apply-audit skill** — Now references findings by stable ID. Added remediation strategies for duplications, terminology drift, vague qualifiers, unresolved placeholders, and zero-coverage requirements.

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
- **deploy.sh** — Now dynamically deploys all commands from `commands/` and all skills from `skill/` (no longer hardcoded). Supports Kiro (`.kiro/prompts/` + `.kiro/skills/`) in addition to opencode.
- **openspec-audit-change skill** — Upgraded from 3 audit categories (accuracy, completeness, validity) to 5 (added feasibility, coherence). Now persists reports to file. Version bumped to 1.1.
- **opsx-apply-audit** — Loads audit findings from persisted files first, falls back to session context. Supports selecting from multiple saved audits.

## 1.0 — Initial release
