## 1. Update default output path in skill

- [x] 1.1 In `skills/security-audit/SKILL.md` line 25, change `~/security-audit-skill/<repo-name>/run-<N>` to `<target>/security-audits/run-<N>` where `<target>` is the target codebase directory
- [x] 1.2 Verify the `run-<N>` numbering logic description remains correct (next unused integer via `ls`)

## 2. Update prior-runs lookup path in skill

- [x] 2.1 In `skills/security-audit/SKILL.md` line 39, change `~/security-audit-skill/<repo-name>/` to `<target>/security-audits/`

## 3. Deploy updated skill

- [x] 3.1 Run `./deploy.sh` to deploy the updated skill to `.opencode/skills/security-audit/`
