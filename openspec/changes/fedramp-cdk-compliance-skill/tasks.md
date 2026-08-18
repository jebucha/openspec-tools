## 1. Skill Structure Setup

- [ ] 1.1 Create skill directory at `.opencode/skills/fedramp-cdk-compliance/`
- [ ] 1.2 Create SKILL.md with main workflow and principles
- [ ] 1.3 Create RECONNAISSANCE.md with Phase 1 prompts
- [ ] 1.4 Create VERIFY.md with Phase 2 agent prompts
- [ ] 1.5 Create REPORTING.md with Phase 3 output format
- [ ] 1.6 Create CONTROLS/ directory structure

## 2. Control Registry

- [ ] 2.1 Create CONTROLS/index.md with FedRAMP 2020 Moderate control registry
- [ ] 2.2 Define AC (Access Control) controls in CONTROLS/ac-controls.md
- [ ] 2.3 Define IA (Authentication) controls in CONTROLS/ia-controls.md
- [ ] 2.4 Define SC (System Protection) controls in CONTROLS/sc-controls.md
- [ ] 2.5 Define AU (Audit) controls in CONTROLS/au-controls.md
- [ ] 2.6 Define CM (Configuration Management) controls in CONTROLS/cm-controls.md

## 3. Service-Specific Verification

- [ ] 3.1 Create SERVICES/ directory structure
- [ ] 3.2 Implement RDS verification checks in SERVICES/rds-checks.md
- [ ] 3.3 Implement ECS verification checks in SERVICES/ecs-checks.md
- [ ] 3.4 Implement Lambda verification checks in SERVICES/lambda-checks.md
- [ ] 3.5 Implement VPC verification checks in SERVICES/vpc-checks.md

## 4. Phase 1: Infrastructure Mapping

- [ ] 4.1 Create resource inventory research agent prompt
- [ ] 4.2 Implement CDK source parsing instructions
- [ ] 4.3 Implement CloudFormation synthesis workflow
- [ ] 4.4 Create control applicability mapping agent prompt
- [ ] 4.5 Define resource relationship mapping
- [ ] 4.6 Implement CloudFormation-only analysis workflow (no CDK toolchain required)

## 5. Phase 2: Control Verification

- [ ] 5.1 Create AC control verification agent prompt
- [ ] 5.2 Create IA control verification agent prompt
- [ ] 5.3 Create SC control verification agent prompt
- [ ] 5.4 Create AU control verification agent prompt
- [ ] 5.5 Create CM control verification agent prompt
- [ ] 5.6 Define evidence citation format
- [ ] 5.7 Create gap identification templates

## 6. Phase 3: Report Generation

- [ ] 6.1 Define compliance report template
- [ ] 6.2 Create structured JSON output schema
- [ ] 6.3 Implement compliance scoring calculation
- [ ] 6.4 Create release comparison report format
- [ ] 6.5 Define remediation task structure

## 7. AWS Documentation Integration

- [ ] 7.1 Create AWS documentation fetching mechanism
- [ ] 7.2 Implement documentation caching strategy
- [ ] 7.3 Define documentation summary format
- [ ] 7.4 Create documentation reference templates

## 8. OpenSpec Integration

- [ ] 8.1 Define OpenSpec remediation change structure
- [ ] 8.2 Create task generation from failed controls
- [ ] 8.3 Implement change organization by control family
- [ ] 8.4 Create remediation guidance templates

## 9. Release Tracking

- [ ] 9.1 Define release tracking directory structure
- [ ] 9.2 Implement release comparison logic
- [ ] 9.3 Create historical data storage format
- [ ] 9.4 Define score tracking mechanism

## 10. Testing and Validation

- [ ] 10.1 Create sample CDK projects for testing
- [ ] 10.2 Implement control verification test cases
- [ ] 10.3 Create compliance scoring validation
- [ ] 10.4 Test AWS documentation fetching and caching
- [ ] 10.5 Validate OpenSpec remediation task generation
