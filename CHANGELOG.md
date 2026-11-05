# https://github.com/jebucha/openspec-tools.git

## 1.5 — 2026-10-09 – 2026-11-05

### Added
- **pi agent deploy target** — `deploy.sh` auto-detects `.pi/` with a new `--pi` force flag. Commands are copied as-is to `.pi/prompts/<name>.md` (filename becomes the `/command` name) and skills to `.pi/skills/*/`.
- **Test Requirement convention** — Spec scenarios describing observable runtime behavior now carry a per-scenario block (ID / File / Command / Pass), and a `## Test Strategy` section in `design.md` declares the runner, full-suite command, and typed prerequisites. Upstream steps read and write these as ordinary markdown.
- **Executable test execution at validate** — `openspec-validate-change` now runs each declared test command verbatim (declared-only, hard 120-second timeout, at most 25 commands) and classifies results by exit code and skip markers. Scenarios without a block fall back to the prior structural check, and a new `Executable tests passed | X/Y (Z%)` coverage-metrics row was added.
- **Executable test audit checks** — `openspec-audit-change` step 6d warns on missing Test Requirement blocks for behavior-changing scenarios and on fake blocks — static-only commands, existential pass criteria, behavior-unrelated commands, or a mocked subject that only verifies the mock (Pattern D). Missing `## Test Strategy` is an Info; fake blocks are excluded from the coverage numerator.
- **Opt-in full-suite regression gate** — `regression: enabled` in Test Strategy (with optional `suite-timeout:` override) makes validate run the declared full-suite command verbatim from the project root (600-second default timeout) and report a `Full suite | Pass/Fail/Not run` row. Skipped tests in the suite produce one Info finding; without the gate, validation is identical to prior behavior.
- **Test-level selection rule** — Every block `openspec-apply-audit` generates or rewrites targets the lowest test level that genuinely exercises the declared outcome (single function/module → unit; process/network/persistence boundary → integration/e2e) and is expected to finish within the 120-second per-block timeout.
- **tests/test_skill_content.sh** — Assertion harness that dogfoods Test Requirement blocks and runs the full suite as a regression gate.

### Changed
- **README.md (workflow)** — "Typical Session" rewritten as the Mixture of Models workflow: each phase in its own fresh session with a role-appropriate model, the human decides at every audit/validate checkpoint (fix / re-audit / proceed / stop), author/reviewer separation and the cost gradient documented, with a lightweight escape hatch kept for small changes. "Looping Back" is now checkpoint-driven instead of an automatic loop-until-clean.
- **Checkpoint prompts** — Follow-up options in the audit, apply-audit, and validate skills reordered and re-framed to match the documented workflow; after apply-audit the first suggested action is a Model C re-audit of the fixed artifacts in a fresh session with a different model.
- **openspec-audit-change skill** — 1.2 → 1.4: added step 6d (presence and fake-block detection, incl. Pattern D) and an Info check for malformed `regression:` / `suite-timeout:` values.
- **openspec-apply-audit skill** — 1.0 → 1.2: added remediation for step 6d findings (generate missing blocks from GIVEN/WHEN/THEN, replace or delete fake blocks) and the test-level selection rule; never enables the regression gate on its own.
- **openspec-validate-change skill** — 1.0 → 1.2: added step 6b (run declared tests) and 6c (opt-in suite gate); replaced the "test checks are structural" guardrail with executable-run guardrails (120s timeout and 25-command cap apply to block commands; the suite is the sole opt-in exception).
- **skills/openspec-apply-audit/README.md** — Prerequisites and "What It Does" wording corrected to match the persisted-file-first audit lookup behavior.

## 1.4 — 2026-08-04 – 2026-08-18

### Added
- **Qwen Code deploy target** — `deploy.sh` auto-detects `.qwen/` with a new `--qwen` force flag; commands and skills are copied as-is in plain markdown (same format as opencode, no conversion).

### Changed
- **README.md (workflow)** — explore promoted to step 1 of the canonical workflow (recommended, not required); validate added as step 6 between apply and archive; new Quality Gates, Looping Back (with diagram), and Validation Dimensions sections; "Typical Session" updated to the full 7 steps; commands and skills tables updated.
- **Validate command renamed** — `opsx-validate-change` → `opsx-validate` for consistency with the other `opsx-` commands.
- **.gitignore** — `.gemini/` entry replaced with `.qwen/`.

### Removed
- **Gemini CLI deploy target (BREAKING)** — Dropped the `--gemini` flag, `.gemini/` auto-detection, and `deploy_gemini()` (including the markdown-to-TOML command conversion). Projects with `.gemini/` are no longer detected as deploy targets and `--gemini` invocations now fail.

## 1.3 — 2026-07-16 – 2026-07-29

### Added
- **opsx-validate command + openspec-validate-change skill** — Independent validation (ideally by a different model than the implementer) of a completed change's implementation against its proposal, specs, design, and audit findings. Structured validation reports with Pass / Conditional / Fail verdicts persist to `openspec/changes/<name>/validations/`.
- **opsx-security-audit command** — New slash command invoking the `security-audit` skill (borrowed from cloudflare/security-audit-skill), accepting an optional target codebase path and output directory.
- **Audit lifecycle** — Stateless lifecycle for persisted audit reports: `opsx-apply-audit` prepends a `## Resolved` header recording which findings were addressed and which deferred, and `opsx-audit` compares new findings against previously resolved ones, flagging regressions when issues reappear.
- **Validation lifecycle** — Validation reports follow the same lifecycle pattern as audits (persisted files, regression detection against prior validations).
- **Gemini CLI deploy target** — `deploy.sh` auto-detects `.gemini/` with a new `--gemini` force flag; commands are converted to Gemini's TOML format (`.gemini/commands/opsx/<name>.toml`) and skills copied to `.gemini/skills/*/`. (Removed again in 1.4.)

### Changed
- **openspec-audit-change skill** — Gained regression detection against previously resolved findings and auto-supersede of older audits (see Removed).
- **openspec-apply-audit skill** — Now requires the selected audit to be in Pending state and writes the `## Resolved` lifecycle header into the audit file it applies.
- **security-audit skill** — Default output location moved from `~/security-audit-skill/<repo-name>/run-<N>` to `<repo-root>/security-audits/run-<N>`, keeping findings under version control; prior-runs discovery updated to match.
- **deploy.sh** — Added `deploy_gemini()` and the `--gemini` flag; auto-detects `.gemini/` alongside opencode, Kiro, and Claude.
- **READMEs** — Per-skill "Files" and "Deployment" sections removed; `skill/` → `skills/` path typos fixed in the top-level README; deployment documentation consolidated in the top-level README only.

### Removed
- **Audit auto-supersede** — Removed days after introduction: new audits no longer mark older audits `Superseded`. All reports remain peers — Pending until one is resolved by `opsx-apply-audit` — preserving the multi-model peer-review workflow. Regression detection (which depends on `## Resolved` headers) is unaffected.

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
