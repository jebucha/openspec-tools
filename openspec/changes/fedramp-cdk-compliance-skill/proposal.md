## Why

The security-audit skill covers code-level security defects but doesn't address infrastructure compliance verification. Security teams need automated FedRAMP compliance checking for CDK infrastructure code as part of their authorization preparation process.

## What Changes

- **New skill**: `fedramp-cdk-compliance` — automated FedRAMP 2020 Moderate compliance verification for CDK infrastructure code
- **Analysis modes**: CDK source parsing and CloudFormation synthesis
- **Outputs**: compliance reports, remediation tasks, per-release tracking

## Capabilities

### New Capabilities

- `fedramp-cdk-compliance`: FedRAMP 2020 Moderate control verification for CDK code

### Modified Capabilities

<!-- No existing capabilities modified -->

## Impact

- **New skill**: `fedramp-cdk-compliance` in `.opencode/skills/`
- **Dependencies**: Requires CDK toolchain for full functionality (optional)
- **Integration**: Produces OpenSpec remediation tasks for tracking
- **Scope**: RDS, ECS, Lambda, VPC services initially
