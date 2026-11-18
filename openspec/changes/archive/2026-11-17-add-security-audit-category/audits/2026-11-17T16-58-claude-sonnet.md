## Resolved: 2026-11-17T17-44
## Resolver: opsx-apply-audit
## Model: qwen3.8-27b
## Status: Fully Resolved

Note: all 10 findings were re-verified and carried over (re-mapped IDs) into the 17:07 qwen3.8-27b audit. They were resolved by the same post-audit artifact edits (17:19-17:20), verified line-by-line and recorded in that audit's resolution header.

### Resolved
- AC-1: Resolved as AC-2 in the 17:07 audit — Non-Goals now cover the validate command files' stale "five dimensions" wording
- AC-2: Resolved as CM-2 in the 17:07 audit — `git diff -U0` mechanism specified in design Context and task 2.2
- CM-1: Resolved as AC-3 in the 17:07 audit — pattern set, exemptions, and credential file names now defined in the spec
- CM-2: Resolved as CM-1 in the 17:07 audit — validate-README scenario and T-CHANGE-SECURITY-CHECKS-021 test added; task 4.3 asserts the validate README
- CM-3: Resolved as CM-3 in the 17:07 audit — task 1.2 covers `SC-` regression-ID matching
- VL-1: Resolved as VL-1 in the 17:07 audit — T-CHANGE-SECURITY-CHECKS-019 added
- VL-2: Resolved as VL-2 in the 17:07 audit — T-CHANGE-SECURITY-CHECKS-020 added
- VL-3: Resolved as VL-4 in the 17:07 audit — no change needed, content-assertion convention accepted
- FS-1: Resolved as FS-1 in the 17:07 audit — task 3.1 updates the finding-ID parsing line to include `SC-1`
- CO-1: Resolved as CO-1 in the 17:07 audit — task 1.1 verification corrected to expect the guardrail line

### Deferred
- None

---

## Audit Report: add-security-audit-category

**Schema:** spec-driven
**Model:** claude-sonnet
**Artifacts checked:** proposal.md, design.md, specs/change-security-checks/spec.md, specs/validate-change/spec.md, tasks.md

### Summary
- Errors: 0
- Warnings: 5
- Info: 5

---

### Findings

| ID | Category | Severity | Description | Evidence |
|----|----------|----------|-------------|----------|
| AC-1 | Accuracy | Warning | `commands/opsx-validate.md` and `.claude/commands/opsx/validate.md` will go stale, and the design's out-of-scope rationale does not cover them | Both say "evaluates the implementation across five dimensions" (line 11) and list no Security dimension. Design Non-Goals only discusses the audit command files ("already list only three categories"). Proposal Impact says "No changes to ... `commands/` files". |
| CM-1 | Completeness | Warning | The secret pattern set is defined only in design.md D5, so the specs cannot be read or tested alone | Spec requirements say "credential-looking value" and "the secret pattern set" (change-security-checks L33, L37, L107) without listing the patterns, placeholder exemptions, or credential-file names. |
| CM-2 | Completeness | Warning | Documentation requirement has no scenario and no test for the validate README clause | "Documentation lists six audit categories" says the validate skill README SHALL describe the Security check. The only scenario covers the top-level README. Task 4.3's `assert_readme_security_category` covers `README.md` and the audit README, not `skills/openspec-validate-change/README.md`. |
| VL-1 | Validity | Warning | Missing test requirement | Scenario "No credentials and no secrets" (change-security-checks L65-67) has no Test Requirement block. It is a behavior-changing outcome ("raise no finding"). |
| VL-2 | Validity | Warning | Missing test requirement | Scenario "Non-security change skips contextual checks" (change-security-checks L102-104) has no Test Requirement block. |
| AC-2 | Accuracy | Info | Design says step 4 "already determines the changed-file set", but 8b needs added lines and new-file contents | Validate SKILL step 4 uses `git diff --name-only` / `git status --porcelain` (file names only). The design and task 2.2 do not say how added lines are obtained. |
| CM-3 | Completeness | Info | Spec 1 says regression detection applies to `SC-` findings, but no scenario or task covers it | change-security-checks L10. D9 accepts the CO-to-SC ID break, but regression matching on SC IDs has no test. |
| VL-3 | Validity | Info | All 20 test blocks are content assertions over skill and README text | Each Command is `bash tests/test_skill_content.sh <assert_fn>`. Under the boundary rule this is accepted, and it matches repo convention. None exercises audit or validate runtime behavior. |
| FS-1 | Feasibility | Info | Apply-audit parses finding IDs with an AC/CM-style example, and no task confirms `SC-` is handled | `skills/openspec-apply-audit/SKILL.md:85` "Parse findings by their stable IDs (AC-1, CM-1, etc.)". Tasks 3.1-3.3 add a remediation block but do not check ID parsing. |
| CO-1 | Coherence | Info | Task 1.1's verification grep cannot pass in isolation | `grep -n "8d\|security surface"` still matches the guardrail at `skills/openspec-audit-change/SKILL.md:455`, which is only rewritten in task 1.5. |

### Coverage Metrics

| Metric | Value |
|--------|-------|
| Total requirements | 10 |
| Total tasks | 21 |
| Requirements with ≥1 task | 10 (100%) |
| Tasks with mapped requirement | 19 (90%) |
| Duplications found | 0 |
| Ambiguities found | 1 |
| Requirements with executable test requirements | 7 (78%) |

Checks that passed:
- Both capability specs exist, and the base `validate-change` spec exists.
- Skill versions (1.4, 1.2, 1.2) and the 461-line baseline match the design.
- The Test Strategy section and `regression: enabled` are valid.
- Step 8d, the guardrail at line 455 and the apply-audit "Security surface omissions" line exist where the artifacts say.
- Dogfood scan: no artifact matches the secret pattern set. design.md D5 uses only prefixes and split private-key markers.

### Verdict
Can proceed with caution. Consider addressing warnings.
