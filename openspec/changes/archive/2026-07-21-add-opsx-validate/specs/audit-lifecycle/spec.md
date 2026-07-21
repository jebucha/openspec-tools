## ADDED Requirements

### Requirement: Validation reports follow audit lifecycle pattern
Validation reports SHALL use the same lifecycle header pattern as audit reports (Superseded, Resolved).

#### Scenario: New validation supersedes older validations
- **WHEN** a new validation report is written and older validation files exist in the same directory
- **THEN** each older validation file receives a `## Superseded` header with the new validation's filename and summary (error/warning counts)

#### Scenario: Supersede headers stack correctly
- **WHEN** multiple validations exist with existing supersede headers
- **THEN** the new supersede header is prepended before all existing headers, preserving the full lifecycle chain

#### Scenario: Validation state derived from headers
- **WHEN** a validation file has a `## Superseded` header pointing to a newer validation
- **THEN** the validation is considered Superseded

#### Scenario: Legacy validation treated as active
- **WHEN** a validation file exists without lifecycle headers
- **THEN** the validation is treated as active until superseded by a newer validation

### Requirement: Regression detection across validations
When a new validation runs, it SHALL compare findings against previously resolved validations to detect regressions.

#### Scenario: Regression detected between validations
- **WHEN** a new validation finding matches a finding ID from a prior validation's resolved list
- **THEN** the new validation report includes a "Regressions" section with the finding ID, description, and reference to the prior validation

#### Scenario: No regression when finding is new
- **WHEN** a new validation finding has no matching resolved finding from prior validations
- **THEN** no regression is flagged

#### Scenario: Regression is a warning
- **WHEN** a regression is detected
- **THEN** it is reported as a Warning severity, not an Error
