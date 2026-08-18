## Context

Security teams need to verify CDK infrastructure code against FedRAMP 20x Moderate (Class C) Key Security Indicators before authorization. Current security-audit skill covers code-level vulnerabilities but not compliance verification.

The skill targets security engineers reviewing CDK code for RDS, ECS, Lambda, and VPC services within FedRAMP authorization boundaries.

## Goals / Non-Goals

**Goals:**
- Automated FedRAMP 20x Moderate (Class C) KSI verification from CDK source
- Structured compliance reporting with AWS documentation references
- OpenSpec remediation task generation
- Per-release compliance tracking with score comparison
- Support for both CDK source analysis and synthesized CloudFormation

**Non-Goals:**
- Post-deployment verification (Security Hub integration is optional)
- All FedRAMP controls (focus on applicable infrastructure controls)
- Non-AWS infrastructure (Terraform, Pulumi)
- FedRAMP High or Low baselines (Moderate only initially)

## Decisions

### Decision 1: Two-Mode Operation

**Choice**: Support both CDK source analysis and CloudFormation-only analysis

**Rationale**: 
- CDK source provides better evidence citations and remediation suggestions
- CloudFormation-only mode allows analysis without CDK toolchain
- Security teams may not have CDK installed or may only have synthesized outputs

**Alternatives Considered**:
- CDK source only: More comprehensive but requires toolchain
- CloudFormation only: Simpler but loses source context

### Decision 2: Weighted vs. Simple Scoring

**Choice**: Simple pass/fail scoring

**Rationale**: 
- Easier to understand and explain to stakeholders
- Less subjective than weight assignment
- Sufficient for compliance tracking

**Alternatives Considered**:
- Weighted scoring: More nuanced but introduces subjectivity

### Decision 3: AWS Documentation Handling

**Choice**: Fetch and summarize at runtime with caching

**Rationale**:
- Ensures current guidance
- Caching reduces network dependency
- Summaries provide context without requiring external access

**Alternatives Considered**:
- Baked-in summaries: Stable but becomes outdated
- URLs only: Requires network access every time

### Decision 4: Remediation Organization

**Choice**: One OpenSpec change per control family

**Rationale**:
- Logical grouping of related fixes
- Smaller, focused changes are easier to review
- Teams can address different control families in parallel

**Alternatives Considered**:
- Single change for all: Too large, harder to track
- One change per control: Too granular, creates overhead

### Decision 5: Control Verification Approach

**Choice**: Deterministic checklist-based verification

**Rationale**:
- Same result every time (unlike exploratory security audit)
- Easier to validate and audit
- Produces binary pass/fail suitable for compliance

**Alternatives Considered**:
- Exploratory approach (like security-audit): Better for finding unknown issues but inconsistent

### Decision 6: Hybrid Control Organization

**Choice**: AWS Security Hub controls as primary unit with FedRAMP 20x KSI mapping as metadata

**Rationale**:
- Security engineers think in terms of AWS controls first ("is my RDS encrypted?")
- KSIs provide compliance context without reorganizing the work
- Both audiences served: DevOps engineers (implementation) and security auditors (compliance)
- Clear AWS documentation references per control
- One-to-many relationship between KSIs and AWS controls is natural

**Alternatives Considered**:
- FedRAMP KSI-led: Better for auditors but obscures implementation details
- AWS-led only: Easier to implement but compliance mapping is secondary

**Structure**:
```
CONTROLS/
├── rds/
│   ├── rds.1.md        # AWS control as primary unit
│   │   KSI: [KSI-CNA-EIS, KSI-CNA-MAT]
│   │   Severity: Critical
│   │   Checks: snapshotPublic property
│   │   └── ...
├── ecs/
├── lambda/
├── vpc/
└── index.md            # KSI → AWS control mapping table
```

## Risks / Trade-offs

| Risk | Mitigation |
|------|------------|
| CDK defaults change over time | Run cdk synth to see actual CloudFormation |
| FedRAMP controls updated | Version control the skill with FedRAMP version |
| AWS documentation changes | Cache documentation with expiration |
| Incomplete coverage | Document known gaps, allow customization |
| False positives from static analysis | Require evidence citation, allow manual override |

## Open Questions

- Should the skill integrate with AWS Security Hub for post-deployment verification?
- How should release tracking be handled (git tags, CI variables)?
- What level of detail should AWS documentation summaries include?
