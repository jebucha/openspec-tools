## 1. Create command file

- [x] 1.1 Create `commands/opsx-security-audit.md` with YAML frontmatter description
- [x] 1.2 Write command body: describe the security audit capability and invoke the `security-audit` skill via the Skill tool
- [x] 1.3 Add input handling: optional target codebase path, with fallback to conversation context or prompt

## 2. Deploy command

- [x] 2.1 Run `./deploy.sh` to deploy the command (`deploy.sh` globs `commands/*.md`, covering `.opencode/commands/` and any other detected environments)

## 3. Update documentation

- [x] 3.1 Add `opsx-security-audit.md` to the commands table in `README.md` under both the `commands/` section and the `.opencode/commands/` section
- [x] 3.2 Add the security-audit skill to the skills table in `README.md` (documentation housekeeping — no spec requirement)
