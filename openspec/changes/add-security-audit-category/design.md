# Design

## Context

See proposal.md for the motivation. This is the current state that shapes the design:

- **Audit skill (v1.4).** It has five categories in steps 4–8. Security exists only as step 8d inside Coherence. That step is contextual and gated by the guardrail "Security checks are contextual". Steps 9–12 cover the report, regression detection, persistence, and follow-up. Output Constraints list the category prefixes AC/CM/VL/FS/CO.
- **Validate skill (v1.2).** It has a single `VD-` prefix with a free-text Category column. Step 8, Code Quality, is Info-only and best-effort, and limited to changed files. Step 4 already determines the changed-file set, by name only (`git diff --name-only` / `git status --porcelain`); the 8b scan additionally obtains added-line content via `git diff -U0` and reads new untracked files in full. Guardrails forbid installs and config or environment edits.
- **Apply-audit (v1.2).** It maps findings to fixes by category and severity. "Security surface omissions" currently sits under the Coherence warnings.
- **In-progress change.** `add-validation-linting` (0/15) plans to insert a new validate step 8 and renumber the steps after it, targeting the deployed copy `.opencode/skills/openspec-validate-change/SKILL.md` (currently stale at v1.1), not the source file this change edits. It also plans an install prompt for missing linters.
- **Deployment.** `deploy.sh` copies `skills/*` byte-for-byte to each target. `tests/deploy_test.sh` checks that copy, and `tests/test_skill_content.sh` holds the content assertions.
- **Existing constraint.** Only the three custom skills, their READMEs, the top-level README, the CHANGELOG, and `tests/test_skill_content.sh` may change. Upstream OpenSpec skills and `commands/` files must not.

## Goals / Non-Goals

**Goals:**
- Security becomes a visible, first-class audit category, and the audit stays about the same size. 8d moves rather than being duplicated.
- An always-on secret floor at both checkpoints: in the plan's artifacts and in the code's diff.
- One escalation path to the `security-audit` skill, never a re-implementation of it.

**Non-Goals:**
- Vulnerability hunting, threat modeling, or dependency CVE lookup. These stay in `security-audit`.
- Scanning git history, or files outside the change's diff.
- Installing or recommending installation of any scanner.
- New Coverage Metrics rows. Security findings appear in the Findings table only.
- Updating `commands/opsx-audit.md`, `commands/opsx-validate.md`, and their `.claude/` copies. The audit files already list only three categories; the validate files' "five dimensions" wording will go stale, but `commands/` files are out of scope under the existing constraint.

## Decisions

**D1: The audit Security section is a new top-level step 9, with steps 9–12 renumbered to 10–13.**
Security is a category peer, so it gets a peer step: "9. Run Security Checks", with sub-checks 9a–9e. The audit has no competing in-flight change, so renumbering is safe. Internal cross-references must move with it: 10a–10d become 11a–11d, and the guardrails reference 9a–9e.
*Alternative:* keep it as 8e or append it after Coherence without a number. Rejected, because the category would read as a Coherence sub-check, which is the problem being fixed.

**D2: The validate security check is sub-step 8b, and Code Quality becomes 8a. There is no top-level renumbering.**
`add-validation-linting` will renumber the top-level validate steps, but on the deployed `.opencode` copy rather than this source file, so the two changes do not collide in the same file; the real coordination risk is source/deployed-copy divergence. Nesting keeps 8a/8b stable against that renumbering when it converges. The Category column (`Security`) is what makes the check visible in reports, not the step number. Sub-step 8b carries its own severities (Error/Warning/Info), which are not bound to Code Quality's Info-only rule.
*Alternative:* a new top-level step 9. Rejected because the linting change's planned top-level renumbering makes any top-level insertion in this change fragile.

**D3: Split into always-run and contextual checks.**
- *Always run:* 9a secrets-in-artifacts and 9b secret-handling-planned. They cost almost nothing (a pattern pass over a few markdown files, plus one question about the design) and produce no findings on clean changes, so running them always adds no noise.
- *Contextual:* 9c input, 9d weakened controls, and 9e escalation. These are semantic judgments that would add noise to cosmetic and refactor changes.

The trigger list is the 8d guardrail's list (auth, user input, data storage, external communication, secrets), extended with permissions and crypto. The escalation check 9e uses the narrower trigger auth, crypto, permissions, or secrets. The error-handling question of old 8d (which the audit README describes as covering input validation, error handling, TLS, and secrets management) is intentionally not carried into the new set: input validation, TLS, and secrets map onto 9c, 9d, and 9a–9b, and error handling is not a security check.

**D4: Severities.**
- *9a, a secret in an artifact, is an Error.* Artifacts are committed and shared. A live credential there is already an exposure, and apply-audit can fix it mechanically.
- *9b, 9c, and 9d are Warnings.* This matches the posture of today's 8d: don't block, but make sure the gap is noticed.
- *9e is Info,* and only one per change.

At validate:
- *A secret hit is an Error,* because it blocks archive.
- *Code-level issues and follow-through gaps are Warnings.*
- *Escalation is one Info.*

**D5: One secret pattern set, duplicated verbatim in the audit and validate skills.**
Each skill is deployed and loaded on its own, so neither can include the other. The set is short so it stays reviewable:
- Private-key headers, matched with the strict pattern `-----BEGIN[A-Z ]*PRIVATE KEY-----` (key-type words and spaces only between the markers), so quoted examples do not match.
- Provider-prefixed tokens, for example `AKIA`, `ghp_`, `github_pat_`, `xox[baprs]-`, `sk_live_`, and `sk-ant-`.
- Credential-named assignments with a literal value of 8 or more characters (`password`, `secret`, `token`, `api_key`, `private_key`).
- URLs with embedded credentials (`scheme://user:pass@`).

These placeholders are exempt: `<…>`, `${…}`, `$VAR`, environment lookups, `changeme`, and values containing `example`, `dummy`, `xxx`, or `redacted`.

The validate skill adds a file-name list:
- Flagged when newly added: `.env`, `.env.*`, `*.pem`, `*.key`, `id_rsa*`, `*.p12`, and `*.pfx`.
- Exempt: `.env.example`, `.env.sample`, and `.env.template`.

A content test asserts that both skills contain the same pattern markers, so the two copies cannot drift silently.
*Alternative:* a shared reference file. Rejected, because skills deploy as self-contained directories.

**D6: Use an existing scanner only if one is installed, with redaction, and never install one.**
The built-in patterns are the contract, so results don't depend on the machine. If `gitleaks` or `trufflehog` is already on PATH, validate may add its hits, but only with redaction enabled, so the scanner's output never carries values. A missing scanner produces no finding. This matches validate's existing "no installs" guardrail and the project's supply-chain baseline. It intentionally differs from the install prompt that `add-validation-linting` plans. If both land, the security check keeps "never install".

**D7: Redaction is a guardrail in all three skills.**
Reports are persisted to `audits/` and `validations/` and may be committed. Evidence for a secrets finding is limited to the file, line, and pattern type, with no prefix, suffix, or length of the value. Apply-audit's own output (plan, diff summary) follows the same rule. Its remediation text tells the user to rotate the credential, because the value was already written to disk and possibly committed. Rotation is a human action outside the tool.

**D8: Validate checks plan follow-through against the design and the latest unresolved audit only.**
Validate already reads design.md. Its follow-through check compares the design's stated secret source and planned input validation against the code. It also lists `SC-` findings from the newest audit file that has no `## Resolved` header. These are evidence-based Warnings that quote the design or finding next to the code location. If no audit exists, only the design comparison runs.

**D9: Stable-ID migration is accepted, not bridged.**
Former 8d findings were `CO-n` and are now `SC-n`. Regression detection matches IDs, so a resolved `CO-n` security finding in an older audit will not be detected as regressed under `SC-n`. A mapping layer would add permanent complexity for a one-time gap. The CHANGELOG records the break.

## Risks / Trade-offs

[Risk] False positives from the credential-assignment pattern in test fixtures → **Mitigation**: the placeholder exemptions and the dummy-marker list. Any remaining hits are Errors the human clears at the checkpoint, which is cheaper than missing a real key.

[Risk] Regex-only scanning misses novel or unprefixed secrets → **Mitigation**: this is a floor, not a guarantee. A scanner can be added when one is installed, and 9e/escalation sends sensitive changes to `security-audit`.

[Risk] The two copies of the pattern set drift apart → **Mitigation**: the `assert_secret_pattern_set` content test fails on drift.

[Risk] Renumbering the audit steps breaks the existing content assertions that grep for step headings such as "6d." → **Mitigation**: steps 4–8 keep their numbers. Only steps 9–12 shift, and the existing tests reference 6d only. The full suite runs as the regression gate.

[Trade-off] The audit gains about 40 lines and validate about 30. That is accepted as "not significantly extending": 8d's 7 lines are removed, and all new checks are single bullets.

[Trade-off] Weakened controls are only a Warning, even though the project baseline says never weaken a control silently. This is accepted because the audit raises the issue, apply-audit requires an explicit human decision, and an Error would block legitimate documented exceptions.

## Test Strategy

```
Runner: bash (plain scripts, no test framework)
Full suite: bash tests/deploy_test.sh && bash tests/test_skill_content.sh
Prerequisites:
  - file: deploy.sh
  - file: tests/deploy_test.sh
  - file: tests/test_skill_content.sh
  - file: skills/openspec-audit-change/SKILL.md
  - file: skills/openspec-apply-audit/SKILL.md
  - file: skills/openspec-validate-change/SKILL.md
  - file: README.md
regression: enabled
```

All blocks are content assertions over the skill and README text, following the convention of earlier changes in this repo. The gate is enabled because the audit renumbering touches text that existing assertions read.

## Migration Plan

No data migration. The change is skill content plus tests. Existing audit files without `SC-` findings continue to work. Rollback is a revert of the three skills, the READMEs, the CHANGELOG entry, and the harness additions.
