# openspec-tools

Agent commands and skills for the [OpenSpec](https://openspec.dev) workflow. These extend AI-assisted development environments (Kiro, opencode, etc.) with structured change management — from proposal through implementation and archive.

## Workflow

```
/opsx-explore  →  /opsx-propose  →  /opsx-audit  →  /opsx-apply-audit  →  /opsx-apply  →  /opsx-validate  →  /opsx-archive
```

| Step | Command | What it does |
|------|---------|--------------|
| 1 | `/opsx-explore` | Thinking partner for exploring ideas, investigating problems, and clarifying requirements (recommended before proposing) |
| 2 | `/opsx-propose` | Describe what you want to build; generates proposal, design, specs, and tasks |
| 3 | `/opsx-audit` | Reviews artifacts for accuracy, completeness, validity, feasibility, and coherence |
| 4 | `/opsx-apply-audit` | Applies audit findings — fixes errors and warnings in the artifacts |
| 5 | `/opsx-apply` | Implements the actual code changes described in the tasks |
| 6 | `/opsx-validate` | Validates implementation against proposal, specs, design, and audit findings |
| 7 | `/opsx-archive` | Archives the completed change with optional spec sync |

In the [Typical Session](#typical-session) below, each step runs in its own fresh session, with a model suited to that step's role.

### Principles

The workflow rests on four principles:

- **Author/reviewer separation** — A model does not grade its own artifacts or code. Audits and validation are done by fresh models that did not write what they are reviewing.
- **Disk is the shared memory** — The change directory (`openspec/changes/<name>/`) is what sessions share; sessions themselves are disposable. Audit reports persist to files, so a later session — with a different model — can pick up exactly where an earlier one left off.
- **The human is the controller** — At every audit and validate checkpoint, the model presents findings and you decide how to proceed (fix / re-audit / proceed / stop). No step advances on a model's judgment alone.
- **Cost gradient** — Expensive models where judgment is required (authoring, auditing, validating); more economical models where the work is mechanical (implementing well-specified, audited tasks).

### Quality Checkpoints

Two checkpoints slow the workflow down where it matters most:

- **Audit (step 3)**: A fresh model reviews the change artifacts before implementation begins — scope gaps, missing specs, infeasible designs, task ordering issues. It presents a structured findings summary (errors, warnings, info); **you decide** what happens next: fix the findings with `/opsx-apply-audit`, re-audit, proceed anyway, or stop.
- **Validate (step 6)**: A fresh model that did not write the code verifies the implementation against what was planned — spec compliance, test coverage, task completion, code quality, regression safety. It presents its findings and verdict; **you decide** whether to fix and re-validate, or archive.

The model informs; the human decides. Neither checkpoint is a model-judged pass/fail gate — "is this good enough?" is your call at each one.

### Looping Back

There is no automatic loop. When an audit or validate presents findings, **you** choose what happens next — fix and re-run, proceed, or stop. Every iteration is a human decision at a checkpoint, never a model deciding the artifacts are "good enough."

```
propose ──→ audit ──→ ◆ you decide ──→ apply-audit ──→ re-audit (fresh model) ──→ ◆ you decide
                      fix / re-audit / (fixes findings)                           fix / re-audit /
                      proceed / stop                                              proceed / stop
```

- **Audit findings**: If you choose to fix, run `/opsx-apply-audit` to fix artifacts, then re-audit with `/opsx-audit` — or proceed to implementation without re-auditing
- **Validate findings**: If you choose to fix, address the issues in code, then re-run `/opsx-validate` — or archive as-is
- **New requirements discovered**: Update artifacts with `/opsx-propose` or manual edits, then re-audit

## Commands

Commands are slash-command definitions that invoke the corresponding skill.

| File | Description |
|------|-------------|
| `commands/opsx-audit.md` | Audit a change proposal for quality issues before implementation |
| `commands/opsx-apply-audit.md` | Apply audit findings and recommendations to change artifacts |
| `commands/opsx-validate.md` | Validate a completed change's implementation against its proposal, specs, and design |
| `commands/opsx-security-audit.md` | Run a comprehensive security audit on a target codebase |

Commands in `.opencode/commands/` (deployed, includes all project commands):
| File | Description |
|------|-------------|
| `opsx-propose.md` | Generate a complete change proposal from a description |
| `opsx-audit.md` | Audit change artifacts |
| `opsx-apply-audit.md` | Fix artifacts based on audit findings |
| `opsx-apply.md` | Implement code changes from tasks |
| `opsx-validate.md` | Validate implementation against proposal, specs, and design |
| `opsx-explore.md` | Explore ideas and investigate problems |
| `opsx-archive.md` | Archive a completed change |
| `opsx-security-audit.md` | Run a comprehensive security audit on a target codebase |

## Skills

Skills contain the detailed step-by-step logic that agents follow when a command is invoked.

| Skill | Purpose |
|-------|---------|
| `skills/openspec-audit-change/` | Structural + semantic audit of change artifacts (accuracy, completeness, validity, feasibility, coherence) |
| `skills/openspec-apply-audit/` | Remediation engine — resolves audit findings by modifying artifacts |
| `skills/openspec-validate-change/` | Validates implementation against proposal, specs, design, and audit findings |
| `skills/security-audit/` | Comprehensive security audit: reconnaissance, threat hunting, validation, and reporting |

Additional skills in `.opencode/skills/` (deployed):
| Skill | Purpose |
|-------|---------|
| `openspec-propose/` | Generates proposal, design, specs, and tasks from user description |
| `openspec-apply-change/` | Implements code changes by working through tasks |
| `openspec-validate-change/` | Validates implementation against proposal, specs, design, and audit findings |
| `openspec-explore/` | Interactive exploration and requirement clarification |
| `openspec-archive-change/` | Archives completed changes with spec sync |
| `security-audit/` | Comprehensive security audit of a target codebase |

## Installation

### Install to your home directory

```bash
./install.sh
```

Copies openspec-tools to `~/.openspec-tools/`.

### Deploy to a project

```bash
./deploy.sh /path/to/your/project
```

Auto-detects the target environment and deploys accordingly:
- `.opencode/` present → commands to `.opencode/commands/`, skills to `.opencode/skills/`
- `.kiro/` present → prompts to `.kiro/prompts/`, skills to `.kiro/skills/`
- `.claude/` present → commands to `.claude/commands/opsx/`, skills to `.claude/skills/`
- `.qwen/` present → commands to `.qwen/commands/`, skills to `.qwen/skills/`
- Multiple present → deploys to all detected environments

Force a specific target with flags:
```bash
./deploy.sh --kiro /path/to/project
./deploy.sh --opencode /path/to/project
./deploy.sh --claude /path/to/project
./deploy.sh --qwen /path/to/project
```

Deploy to the current directory:

```bash
./deploy.sh .
```

## Project Structure

```
openspec-tools/
├── commands/                   # Source command definitions (deployed by deploy.sh)
│   ├── opsx-audit.md
│   ├── opsx-apply-audit.md
│   ├── opsx-validate.md
│   └── opsx-security-audit.md
├── skills/                     # Source skill definitions (deployed by deploy.sh)
│   ├── openspec-audit-change/
│   │   ├── README.md
│   │   └── SKILL.md
│   ├── openspec-apply-audit/
│   │   ├── README.md
│   │   └── SKILL.md
│   ├── openspec-validate-change/
│   │   ├── README.md
│   │   └── SKILL.md
│   └── security-audit/
│       ├── README.md
│       ├── SKILL.md
│       └── ... (hunting reference docs, report schema, validator)
├── .opencode/                  # Deployed commands + skills (local dev use)
│   ├── commands/
│   └── skills/
├── .kiro/                      # Kiro-specific prompts and skills
│   ├── prompts/
│   └── skills/
├── .qwen/                      # Qwen Code commands and skills
│   ├── commands/
│   └── skills/
├── openspec/                   # OpenSpec config and change history
│   ├── config.yaml
│   ├── changes/
│   └── specs/
├── deploy.sh                   # Deploy commands + skills to a target project
├── install.sh                  # Install toolset to ~/.openspec-tools
├── CHANGELOG.md
└── LICENSE                     # MIT
```

## Audit Categories

The `/opsx-audit` command evaluates artifacts across five dimensions:

| Category | What it checks |
|----------|---------------|
| **Accuracy** | Capability names match between proposal and specs; referenced files exist; no contradictory specs |
| **Completeness** | Required artifacts present; requirements have scenarios; tasks have spec coverage; no empty sections |
| **Validity** | Requirements are testable; task dependencies resolve; naming conventions followed |
| **Feasibility** | Design references match actual codebase; dependencies are available; patterns align with conventions |
| **Coherence** | Proposal ↔ design scope aligned; specs have design support; tasks ordered buildably; security surface covered |

Findings are categorized by severity:
- **Error** — Blocks implementation. Must be resolved.
- **Warning** — Should be addressed. Proceed with caution.
- **Info** — Awareness only. Optional to address.

## Validation Dimensions

The `/opsx-validate` command evaluates implementations across five dimensions:

| Dimension | What it checks |
|-----------|---------------|
| **Spec compliance** | Are spec requirements satisfied by the actual code? |
| **Test coverage** | Do tests exist for new requirements and edge cases? |
| **Task completion** | Are all tasks completed and reflected in the codebase? |
| **Code quality** | Are there obvious issues in changed files? |
| **Regression safety** | Do changes break existing functionality patterns? |

Findings are categorized by severity:
- **Error** — Blocks readiness. Must be resolved before archiving.
- **Warning** — Should be addressed. Proceed with caution.
- **Info** — Awareness only. Optional to address.

The verdict indicates readiness:
- **Pass** — No errors; implementation validated, ready for archive.
- **Conditional** — Only warnings; proceed with caution.
- **Fail** — Errors exist; cannot proceed, resolve errors first.

## Audit Persistence

Audit reports are saved as files within the change directory:

```
openspec/changes/<name>/audits/<timestamp>-<model>.md
```

This enables:
- **Multi-LLM comparison** — Run the same audit with different models, compare findings
- **Historical tracking** — See how findings change across iterations (pre-fix vs post-fix)
- **Decoupled workflow** — Audit and apply-audit don't need to happen in the same session
- **Selective application** — Choose which audit's findings to apply when multiple exist

Example:
```
openspec/changes/add-user-auth/audits/
├── 2026-07-09T15-42-claude-opus.md
├── 2026-07-09T15-50-gemini-pro.md
└── 2026-07-09T16-01-claude-opus.md   ← post-fix re-audit
```

## Typical Session

The typical session is a **Mixture of Models** flow: each phase runs in its own fresh session, staffed by the kind of model the phase calls for. A, B, and C are *roles*, not specific models — map them to whatever you have available.

| Session | Role | Command | What happens |
|---------|------|---------|--------------|
| 1 | **Model A** — strong author | `/opsx-explore` + `/opsx-propose` | Explores the problem, then writes the proposal, design, and tasks |
| 2 | **Model B** — fresh auditor | `/opsx-audit` | Reviews Model A's artifacts and **presents findings** → **you choose**: fix / re-audit / proceed / stop |
| 3 | Any model | `/opsx-apply-audit` | Fixes the findings you chose to fix; writes a `## Resolved` header into the audit file so the next run sequences to the remaining work |
| 4 | **Model C** — second-opinion auditor | `/opsx-audit` | Re-audits the *fixed* artifacts in a fresh session (serial, so its findings are against current state) and **presents findings** → **you choose** again |
| 5 | More-economical implementer | `/opsx-apply` | Implements the tasks. The proposal, design, and tasks are now well-defined and audited, so implementation is more mechanical — a cost-strategy fit, not a corner cut |
| 6 | **Model B or C** — fresh validator (not the coder) | `/opsx-validate` | Validates the implementation against the artifacts and **presents findings** → **you choose**: fix / re-validate / archive |
| 7 | Any model | `/opsx-archive` | Archives the completed change with optional spec sync |

```bash
# Session 1 — Model A (strong author)
/opsx-explore "How should we handle user authentication?"
/opsx-propose add-user-auth

# Session 2 — Model B (fresh auditor)
/opsx-audit add-user-auth
# → findings presented; you choose: fix / re-audit / proceed / stop

# Session 3 — any model (if you chose to fix)
/opsx-apply-audit add-user-auth

# Session 4 — Model C (second-opinion auditor, fresh session)
/opsx-audit add-user-auth
# → findings on the fixed artifacts presented; you choose again

# Session 5 — more-economical implementer
/opsx-apply add-user-auth

# Session 6 — Model B or C (fresh validator, not the model that wrote the code)
/opsx-validate add-user-auth
# → findings presented; you choose: fix / re-validate / archive

# Session 7 — any model
/opsx-archive add-user-auth
```

The two-audit shape (B, then C) is the documented focus, not a quota — you may run more audit/fix cycles, or proceed earlier, at any checkpoint.

> **Escape hatch:** For small, low-risk changes, collapse the phases into a single model and session — run the seven commands above in one session, the way the pre-multi-model flow did. The full Mixture of Models flow is warranted for high-stakes changes, unfamiliar codebases, or security-sensitive work.

## Requirements

- [OpenSpec CLI](https://openspec.dev) installed and initialized in the target project
- An AI development environment that supports slash commands (Kiro, opencode, etc.)

## License

MIT — see [LICENSE](LICENSE).
