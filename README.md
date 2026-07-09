# openspec-tools

Agent commands and skills for the [OpenSpec](https://openspec.dev) workflow. These extend AI-assisted development environments (Kiro, opencode, etc.) with structured change management — from proposal through implementation and archive.

## Workflow

```
/opsx-propose  →  /opsx-audit  →  /opsx-apply-audit  →  /opsx-apply  →  /opsx-archive
```

| Step | Command | What it does |
|------|---------|--------------|
| 1 | `/opsx-propose` | Describe what you want to build; generates proposal, design, specs, and tasks |
| 2 | `/opsx-audit` | Reviews artifacts for accuracy, completeness, validity, feasibility, and coherence |
| 3 | `/opsx-apply-audit` | Applies audit findings — fixes errors and warnings in the artifacts |
| 4 | `/opsx-apply` | Implements the actual code changes described in the tasks |
| 5 | `/opsx-archive` | Archives the completed change with optional spec sync |

Additional:
| Command | What it does |
|---------|--------------|
| `/opsx-explore` | Thinking partner for exploring ideas, investigating problems, and clarifying requirements |

## Commands

Commands are slash-command definitions that invoke the corresponding skill.

| File | Description |
|------|-------------|
| `command/opsx-audit.md` | Audit a change proposal for quality issues before implementation |
| `command/opsx-apply-audit.md` | Apply audit findings and recommendations to change artifacts |

Commands in `.opencode/commands/` (deployed, includes all project commands):
| File | Description |
|------|-------------|
| `opsx-propose.md` | Generate a complete change proposal from a description |
| `opsx-audit.md` | Audit change artifacts |
| `opsx-apply-audit.md` | Fix artifacts based on audit findings |
| `opsx-apply.md` | Implement code changes from tasks |
| `opsx-explore.md` | Explore ideas and investigate problems |
| `opsx-archive.md` | Archive a completed change |

## Skills

Skills contain the detailed step-by-step logic that agents follow when a command is invoked.

| Skill | Purpose |
|-------|---------|
| `skill/openspec-audit-change/` | Structural + semantic audit of change artifacts (accuracy, completeness, validity, feasibility, coherence) |
| `skill/openspec-apply-audit/` | Remediation engine — resolves audit findings by modifying artifacts |

Additional skills in `.kiro/skills/` (deployed):
| Skill | Purpose |
|-------|---------|
| `openspec-propose/` | Generates proposal, design, specs, and tasks from user description |
| `openspec-apply-change/` | Implements code changes by working through tasks |
| `openspec-explore/` | Interactive exploration and requirement clarification |
| `openspec-archive-change/` | Archives completed changes with spec sync |

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

Copies all commands to `.opencode/commands/` and all skills to `.opencode/skills/` in the target project. The target must already have `.opencode/` initialized (run `openspec init` first).

Deploy to the current directory:

```bash
./deploy.sh .
```

## Project Structure

```
openspec-tools/
├── command/                    # Source command definitions (deployed by deploy.sh)
│   ├── opsx-audit.md
│   └── opsx-apply-audit.md
├── skill/                      # Source skill definitions (deployed by deploy.sh)
│   ├── openspec-audit-change/
│   │   └── SKILL.md
│   └── openspec-apply-audit/
│       ├── SKILL.md
│       └── README.md
├── .opencode/                  # Deployed commands + skills (local dev use)
│   ├── commands/
│   └── skills/
├── .kiro/                      # Kiro-specific prompts and skills
│   ├── prompts/
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

## Typical Session

```bash
# 1. Propose a change
/opsx-propose add-user-auth

# 2. Audit the generated artifacts
/opsx-audit add-user-auth

# 3. If findings exist, fix them
/opsx-apply-audit add-user-auth

# 4. Re-audit to confirm clean (optional)
/opsx-audit add-user-auth

# 5. Implement the code
/opsx-apply add-user-auth

# 6. Archive when done
/opsx-archive add-user-auth
```

## Requirements

- [OpenSpec CLI](https://openspec.dev) installed and initialized in the target project
- An AI development environment that supports slash commands (Kiro, opencode, etc.)

## License

MIT — see [LICENSE](LICENSE).
