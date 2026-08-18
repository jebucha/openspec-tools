## Audit Report: fedramp-cdk-compliance-skill

**Schema:** spec-driven
**Model:** deepseek-v4-flash
**Artifacts checked:** proposal.md, design.md, specs/fedramp-cdk-compliance/spec.md, tasks.md

### Summary
- Errors: 0
- Warnings: 2
- Info: 5

### Findings

| ID | Category | Severity | Description | Evidence |
|----|----------|----------|-------------|----------|
| CO-1 | Coherence | Warning | CloudFormation-only mode promised but unimplemented | Design Decision 1 "Support both CDK source analysis and CloudFormation-only analysis" — no spec requirement or task covers analyzing CloudFormation without the CDK toolchain; spec req "CloudFormation synthesis" only covers `cdk synth` |
| VL-1 | Validity | Warning | Vague qualifier in requirement | spec.md L4 "parse CDK source code to inventory all AWS resources" — scenario L6 says "complete resource inventory" with no measurable definition of completeness |
| AC-1 | Accuracy | Info | Terminology drift | design.md uses "per-release tracking" / "release comparison" while tasks 9.x use "Version Tracking" / "version comparison" for the same concept |
| VL-2 | Validity | Info | Redundant capability listing in proposal | proposal.md L9-11 "### New Capability" and L15-17 "### Capabilities / New Capabilities" both list the identical `fedramp-cdk-compliance` capability |
| FS-1 | Feasibility | Info | New skill structure deviates from existing pattern | `.opencode/skills/security-audit/` uses flat companion files (RECONNAISSANCE.md, HUNTING.md); proposed CONTROLS/ and SERVICES/ subdirectories introduce a new layout |
| CO-2 | Coherence | Info | Spec scope broader than registry | spec.md L18 requires determining "which FedRAMP 2020 Moderate controls apply" but tasks 2.2-2.6 only define 5 families (AC, IA, SC, AU, CM) — aligned with design non-goal but spec wording is unbounded |
| CM-1 | Completeness | Info | Tasks without direct requirement mapping | Section 1 (skill structure, 6 tasks) and Section 10 (testing/validation, 5 tasks) map to no specific spec requirement — implementation detail |

### Coverage Metrics

| Metric | Value |
|--------|-------|
| Total requirements | 9 |
| Total tasks | 51 |
| Requirements with ≥1 task | 9 (100%) |
| Tasks with mapped requirement | 40 (78%) |
| Duplications found | 0 |
| Ambiguities found | 1 |

### Verdict
Can proceed with caution. Consider addressing warnings.