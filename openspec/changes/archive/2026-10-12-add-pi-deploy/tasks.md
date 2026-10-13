# Tasks

## 1. Pi deployment in deploy.sh

- [x] 1.1 Add `--pi` to the argument-parsing case statement (sets `FORCE_ENV="pi"`) and add `--pi` to the "Valid options" error message. Verify: `bash deploy.sh --pi <tmpdir>` no longer reports "Unknown option", and `bash deploy.sh --bogus <tmpdir>` error output lists `--pi`.
- [x] 1.2 Add `.pi/` auto-detection to the environment-detection block (`[[ -d "$TARGET/.pi" ]] && ENVS="${ENVS:+$ENVS }pi"`), after the qwen line. Verify: in a temp dir containing only `.pi/`, `bash deploy.sh <dir>` exits 0 and the summary line lists `pi`.
- [x] 1.3 Add a `deploy_pi()` function — copy each `commands/*.md` as-is to `.pi/prompts/` (creating the directory), copy each `skills/*/` directory unchanged to `.pi/skills/`, printing `  [pi] command: <name>.md` and `  [pi] skill: <name>` lines — and add the `pi) deploy_pi ;;` dispatch branch. Verify: in a temp dir with `.pi/`, `bash deploy.sh <dir>` copies every source command to `.pi/prompts/` and every source skill to `.pi/skills/`, with `cmp`/`diff -r` confirming content is byte-identical.
- [x] 1.4 Update the "No supported environment" error block: add `.pi/` to the "Expected one of" list and add a pi initialization hint (`openspec init --tools pi → creates .pi/`) to the "Initialize one of" list. Verify: `bash deploy.sh <empty dir>` exits 1 and the message lists both `.pi/` and `--pi`.

## 2. Pi test coverage (tests/deploy_test.sh)

- [x] 2.1 Add a pi test block mirroring the existing qwen block: auto-detection (deploy with only `.pi/` present exits 0, summary lists pi, all source commands land in `.pi/prompts/`), force flag (`--pi` deploys only pi even with `.opencode/` present), commands as-is (`cmp` against source), skills unchanged (`diff -r`), and progress lines (`  [pi] command:` / `  [pi] skill:`). Verify: `bash tests/deploy_test.sh` runs the new pi assertions and they pass.
- [x] 2.2 Update the shared assertions for the new environment: the no-environment error checks must also assert the message lists `.pi/` and `--pi`, the unknown-flag check must assert `--pi` is listed as valid, and the regression-sanity section gains a pi case (deploy with only `.pi/` present, all commands present in `.pi/prompts/`). Verify: full `bash tests/deploy_test.sh` run exits 0 with zero failures.

## 3. Docs and housekeeping

- [x] 3.1 Update the README deployment section: add `.pi/` present → prompts to `.pi/prompts/`, skills to `.pi/skills/` to the auto-detection list, and add `./deploy.sh --pi /path/to/project` to the force-flag examples. Verify: README lists all five environments and all five flags.
- [x] 3.2 Add `.pi/` to `.gitignore` alongside the other four deploy-target directories. Verify: `git check-ignore .pi` exits 0.

## 4. Integration check

- [x] 4.1 End-to-end deploy into this repo: run `bash deploy.sh .` (this repo has a `.pi/` directory) and confirm the four source commands land in `.pi/prompts/` and the four source skills in `.pi/skills/`, byte-identical to the sources, without disturbing the existing core openspec files already in `.pi/`. Verify: `cmp`/`diff -r` against `commands/` and `skills/` for every deployed file, and the pre-existing `.pi/prompts/opsx-explore.md` etc. still present.
