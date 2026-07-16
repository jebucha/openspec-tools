## ADDED Requirements

### Requirement: Audit resolution tracking
When `opsx-apply-audit` successfully resolves findings, it SHALL prepend a resolution header to the audit file documenting which findings were addressed and which were deferred.

#### Scenario: Resolution header created on successful apply
- **WHEN** `opsx-apply-audit` resolves findings from an audit report
- **THEN** a `## Resolved` header is prepended to the audit file containing timestamp, resolver, model, resolved findings, and deferred findings

#### Scenario: Original audit content preserved
- **WHEN** resolution header is prepended to an audit file
- **THEN** the original audit report content remains unchanged below a `---` separator

### Requirement: Auto-supersede older audits
When `opsx-audit` creates a new audit report, it SHALL automatically prepend a supersede header to existing audit files in the same directory.

#### Scenario: Older audit marked as superseded
- **WHEN** `opsx-audit` writes a new audit report to `audits/` and older audit files exist
- **THEN** each older audit file receives a `## Superseded` header with the new audit's filename and summary (error/warning counts)

#### Scenario: Supersede headers stack correctly
- **WHEN** multiple audits exist with existing resolution or supersede headers
- **THEN** the new supersede header is prepended before all existing headers, preserving the full lifecycle chain

### Requirement: Regression detection
When `opsx-audit` runs and a resolved audit exists, it SHALL compare new findings against previously resolved findings and flag any regressions.

#### Scenario: Regression detected and flagged
- **WHEN** a new audit finding matches a finding ID from a resolved audit's resolved list
- **THEN** the new audit report includes a "Regressions" section with the finding ID, description, and reference to the resolved audit file

#### Scenario: No regression when finding is new
- **WHEN** a new audit finding has no matching resolved finding from prior audits
- **THEN** no regression is flagged

#### Scenario: Regression is a warning, not an error
- **WHEN** a regression is detected
- **THEN** it is reported as a Warning severity, not an Error, allowing the user to proceed

### Requirement: Audit state derived from headers and timestamps
The state of an audit file SHALL be derived from its headers and the presence of newer audit files, not from explicit status fields.

#### Scenario: Pending state for audit without resolution header
- **WHEN** an audit file has no `## Resolved` header and no newer audit file exists
- **THEN** the audit is considered Pending

#### Scenario: Resolved state for audit with resolution header
- **WHEN** an audit file has a `## Resolved` header and no newer audit file exists
- **THEN** the audit is considered Resolved

#### Scenario: Superseded state when newer audit exists
- **WHEN** an audit file has a `## Superseded` header pointing to a newer audit file
- **THEN** the audit is considered Superseded

### Requirement: Apply-audit requires pending state
`opsx-apply-audit` SHALL only operate on audits in Pending state by default.

#### Scenario: Apply-audit skips resolved audits
- **WHEN** `opsx-apply-audit` runs and the only available audit is Resolved or Superseded
- **THEN** the user is informed that no pending audits are available and offered to run a new audit

#### Scenario: Apply-audit selects pending audit automatically
- **WHEN** multiple audits exist and one is in Pending state
- **THEN** the pending audit is selected automatically without user prompt

### Requirement: Backward compatibility with existing audits
Audit files without lifecycle headers SHALL continue to function correctly.

#### Scenario: Legacy audit treated as pending
- **WHEN** an audit file exists without `## Resolved` or `## Superseded` headers
- **THEN** the audit is treated as Pending and can be applied normally

#### Scenario: New headers do not break existing parsing
- **WHEN** a new audit report is generated
- **THEN** the report can be parsed correctly whether or not it contains lifecycle headers
