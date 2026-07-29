## Purpose

Remove auto-supersede behavior from audit and validation reports. All reports are peers — no report supersedes another on creation.

## Requirements

### Requirement: Auto-supersede removed from audit reports

When `opsx-audit` creates a new audit report, it SHALL NOT modify existing audit files in the same directory.

#### Scenario: Older audits remain unmodified
- **WHEN** `opsx-audit` writes a new audit report to `audits/` and older audit files exist
- **THEN** the older audit files are not modified — no `## Superseded` header is added

#### Scenario: Multiple audits all remain pending
- **WHEN** audits from multiple models exist in `audits/`
- **THEN** all audits without a `## Resolved` header are considered Pending

### Requirement: Auto-supersede removed from validation reports

When `opsx-validate` creates a new validation report, it SHALL NOT modify existing validation files in the same directory.

#### Scenario: Older validations remain unmodified
- **WHEN** `opsx-validate` writes a new validation report to `validations/` and older validation files exist
- **THEN** the older validation files are not modified — no `## Superseded` header is added

### Requirement: Audit state model simplified to Pending and Resolved

The state of an audit file SHALL be derived from the presence of a `## Resolved` header only.

#### Scenario: Pending state for audit without resolution header
- **WHEN** an audit file has no `## Resolved` header
- **THEN** the audit is considered Pending

#### Scenario: Resolved state for audit with resolution header
- **WHEN** an audit file has a `## Resolved` header
- **THEN** the audit is considered Resolved

### Requirement: Apply-audit operates on Pending audits

`opsx-apply-audit` SHALL only operate on audits in Pending state by default.

#### Scenario: Apply-audit skips resolved audits
- **WHEN** `opsx-apply-audit` runs and the only available audit is Resolved
- **THEN** the user is informed that no pending audits are available and offered to run a new audit

#### Scenario: Apply-audit lists multiple pending audits
- **WHEN** multiple Pending audits exist
- **THEN** the user is presented with all Pending audits and prompted to select one

### Requirement: Regression detection unchanged

Regression detection SHALL continue to function based on `## Resolved` headers from prior audits and validations.

#### Scenario: Regression detected from resolved audit
- **WHEN** a new audit finding matches a finding ID from a resolved audit's resolved list
- **THEN** the new audit report includes a "Regressions" section

#### Scenario: Regression detection does not depend on supersede
- **WHEN** regression detection runs
- **THEN** it examines only `## Resolved` headers, not `## Superseded` headers
