# Proposal

## Why

Security is a one-line afterthought in the audit today: step 8d "Security surface awareness" is buried inside Coherence, runs only when the change touches certain surfaces, and has no counterpart at validate. So nothing catches a credential pasted into a design or committed in the implementation diff. The `security-audit` skill handles exhaustive analysis, but it is heavy and opt-in. The plan-to-code pipeline needs a lightweight, always-present security floor that points to `security-audit` when deeper review is warranted.

## What Changes

- **New audit category: Security (`SC-`)** in `openspec-audit-change`, a peer of the existing five. Step 8d moves out of Coherence and becomes this category's contextual checks. The category has five checks:
  - **Always run**
    - Secrets in artifacts: Error
    - Secret handling planned: Warning
  - **Contextual** (same trigger list as today's 8d)
    - Untrusted input handling: Warning
    - Weakened security controls: Warning
    - Escalation to `/opsx-security-audit`: Info
- **New validate check: Security** in `openspec-validate-change`, a best-effort sub-step beside Code quality with Category `Security`:
  - A secret scan of the change's added lines and new files, using a fixed pattern set. A secret scanner is used only if it is already installed, and the skill never installs one. A hit is an Error.
  - Injection, disabled-control, and supply-chain checks on changed files: Warning.
  - Follow-through on what the design and the latest unresolved audit's `SC-` findings promised: Warning.
  - The same escalation Info as the audit.
- **Secret values are never reproduced** in any audit, validation, or apply-audit output. Findings cite file, line, and pattern type only, because reports are persisted to disk.
- **`openspec-apply-audit`** gains a Security remediation block. "Security surface omissions" moves out of Coherence. A new fix for a secret found in an artifact replaces the literal with an env-var or secrets-manager reference and tells the user to rotate the exposed credential.
- **Docs:** the top-level README and the audit and validate READMEs change "five" to "six" and add Security rows. The CHANGELOG notes that security findings formerly reported as `CO-n` are now `SC-n`, so regression detection will not match resolved `CO-n` security findings from earlier audits against new `SC-n` IDs.

## Capabilities

### New Capabilities
- `change-security-checks`: Lightweight security checks across the change lifecycle. It covers the audit Security category (`SC-`), its always-run and contextual checks, apply-audit remediation for `SC-` findings, the validate Security check and secret scan, the shared secret-pattern set, the no-secret-reproduction rule for reports, and escalation to the `security-audit` skill.

### Modified Capabilities
- `validate-change`: Adds a requirement that validation runs the Security check on the change's diff, alongside the existing compliance, coverage, task, quality, and regression checks.

## Impact

- `skills/openspec-audit-change/SKILL.md`: new step 9 "Run Security Checks", 8d removed from Coherence, later steps renumbered (9 to 10 through 12 to 13), `SC-` added to Output Constraints, guardrail rewritten, and examples updated. Version 1.4 becomes 1.5.
- `skills/openspec-validate-change/SKILL.md`: step 8 split into 8a Code quality and 8b Security, with no top-level renumbering. Category `Security`, the redaction guardrail, and the no-install guardrail are added. Version 1.2 becomes 1.3.
- `skills/openspec-apply-audit/SKILL.md`: Security remediation block and redaction rule. Version 1.2 becomes 1.3.
- `skills/*/README.md` for the three skills, top-level `README.md`, and `CHANGELOG.md`.
- `tests/test_skill_content.sh`: new content assertions.
- No new dependencies. Optional use of an already-installed secret scanner only.
- No changes to upstream OpenSpec skills or to `commands/` files.
