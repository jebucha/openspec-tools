## ADDED Requirements

### Requirement: Resource inventory from CDK source
The skill SHALL parse CDK source code to inventory all AWS resources and their relationships.

#### Scenario: Successful inventory
- **WHEN** CDK source is provided
- **THEN** skill produces an inventory listing every AWS resource construct defined in the source, each with its resource type and dependency edges to other resources

### Requirement: CloudFormation synthesis
The skill SHALL run `cdk synth` to generate CloudFormation templates for analysis.

#### Scenario: Synthesis succeeds
- **WHEN** CDK source is provided and CDK toolchain is available
- **THEN** skill generates CloudFormation templates for verification

### Requirement: CloudFormation-only analysis
The skill SHALL analyze synthesized CloudFormation templates directly when CDK source or the CDK toolchain is unavailable.

#### Scenario: Direct CloudFormation analysis
- **WHEN** CloudFormation templates are provided without CDK source
- **THEN** skill performs control verification against the templates directly

### Requirement: Control applicability mapping
The skill SHALL determine which FedRAMP 2020 Moderate controls from the supported families (AC, IA, SC, AU, CM) apply based on deployed resources.

#### Scenario: RDS controls identified
- **WHEN** RDS resources are found in CDK
- **THEN** skill identifies applicable controls (SC-12, IA-2, AU-2, etc.)

### Requirement: Control verification
The skill SHALL verify each applicable FedRAMP control against CDK source and synthesized CloudFormation.

#### Scenario: Control passes
- **WHEN** control requirements are met in CDK code
- **THEN** skill marks control as passed with evidence citation

#### Scenario: Control fails
- **WHEN** control requirements are not met
- **THEN** skill marks control as failed with gap description

### Requirement: Compliance scoring
The skill SHALL calculate an overall compliance score based on pass/fail results.

#### Scenario: Score calculation
- **WHEN** all controls are verified
- **THEN** skill calculates score as (passed / applicable) × 100

### Requirement: AWS documentation reference
The skill SHALL reference relevant AWS documentation for each control verification.

#### Scenario: Documentation cited
- **WHEN** control is verified
- **THEN** skill includes AWS documentation URL and summary

### Requirement: Remediation task generation
The skill SHALL generate OpenSpec remediation tasks for failed controls.

#### Scenario: Tasks generated
- **WHEN** controls fail verification
- **THEN** skill creates OpenSpec changes with remediation tasks

### Requirement: Per-release tracking
The skill SHALL track compliance scores and changes between releases.

#### Scenario: Release comparison
- **WHEN** previous release data exists
- **THEN** skill produces comparison showing score changes and control deltas

### Requirement: Structured output
The skill SHALL produce both human-readable reports and machine-readable JSON output.

#### Scenario: Report generated
- **WHEN** verification is complete
- **THEN** skill generates compliance report and findings JSON
