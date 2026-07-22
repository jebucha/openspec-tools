## 1. Add gemini detection and flag

- [x] 1.1 Add `--gemini` to the argument parsing case statement in deploy.sh
- [x] 1.2 Add `.gemini/` directory check to the auto-detection block
- [x] 1.3 Add `gemini` to the error message listing supported environments

## 2. Implement deploy_gemini function

- [x] 2.1 Create `deploy_gemini()` function that converts `commands/*.md` to `.gemini/commands/opsx/<name>.toml`
- [x] 2.2 Implement markdown-to-TOML conversion: extract description, wrap content as triple-quoted `prompt`, escape `"""` sequences
- [x] 2.3 Strip `opsx-` prefix from command filenames for gemini output
- [x] 2.4 Deploy skills from `skills/*/` to `.gemini/skills/*/` (same as opencode)
- [x] 2.5 Add progress output lines in `[gemini]` format for commands and skills

## 3. Wire deploy_gemini into the deployment loop

- [x] 3.1 Add `gemini) deploy_gemini ;;` case to the deployment loop

## 4. Update documentation

- [x] 4.1 Update README.md to document gemini support in the deployment section
- [x] 4.2 Update README.md project structure to include `.gemini/`
