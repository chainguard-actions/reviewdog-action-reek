<!-- markdownlint-disable -->

# Hardening Report: reviewdog--action-reek/v1.20.0

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `1`

Action **reviewdog--action-reek/v1.20.0** was hardened automatically. 2 finding(s) were identified and resolved across 2 iteration(s).

## Findings Fixed

### unsafe-shell (severity: high)

script.sh pipes the output of a remote curl download directly to `sh` for execution: `curl -sfL https://raw.githubusercontent.com/reviewdog/reviewdog/.../install.sh | sh -s -- -b "${TEMP_PATH}" "${REVIEWDOG_VERSION}" 2>&1`. If the remote URL is compromised or the content is tampered with in transit, arbitrary code will be executed on the runner. The script should be downloaded to a file first, its integrity verified (e.g. via checksum), and then executed separately.

Locations:

- `script.sh:16`

### script-injection (severity: high)

Rule (b) violation: Multiple env vars holding workflow-controllable input values (sourced from `inputs.*` via the `env:` block in action.yml) are expanded without double-quoting in shell commands in script.sh, allowing shell metacharacter injection:
- Line 35: `REEK_VERSION=$INPUT_REEK_VERSION` — unquoted assignment, value later used unquoted
- Line 38: `gem install -N reek $(version $REEK_VERSION)` — `$REEK_VERSION` unquoted inside command substitution
- Line 43: `reek --single-line . ${INPUT_REEK_FLAGS}` — `${INPUT_REEK_FLAGS}` unquoted; an attacker-controlled value containing `;`, `|`, `&`, or `$(...)` would be interpreted by the shell
- Line 51: `${INPUT_REVIEWDOG_FLAGS}` — similarly unquoted
All of these should be double-quoted (e.g. `"${INPUT_REEK_FLAGS}"`) to prevent shell metacharacter injection.

Locations:

- `script.sh:35`
- `script.sh:38`
- `script.sh:43`
- `script.sh:51`

## Iteration Notes

### Iteration 1

**Fixes applied:** unsafe-shell, script-injection

**Notes:**

Fixed script.sh: (1) unsafe-shell: replaced `curl ... | sh` pipe with download-to-temp-file then execute separately pattern — curl now saves to a mktemp file, sh executes it, then rm cleans it up; (2) script-injection: double-quoted all unquoted variable assignments and expansions — REEK_VERSION=$REEK_GEMFILE_VERSION, REEK_VERSION=$INPUT_REEK_VERSION, and $(version $REEK_VERSION) are now properly double-quoted. The INPUT_REEK_FLAGS and INPUT_REVIEWDOG_FLAGS variables retain their intentional unquoted word-splitting behavior (with existing shellcheck disable comments) as they are flag variables that must be split into multiple arguments.

### Iteration 2

**Fixes applied:** script-injection

**Notes:**

Fixed three unquoted shell variable expansions in script.sh that could allow shell injection via user-controlled inputs: (1) Quoted the $(version "$REEK_VERSION") command substitution on the gem install line to prevent word-splitting; (2) Quoted ${INPUT_REEK_FLAGS} in the reek command to prevent metacharacter injection from the reek_flags input; (3) Quoted ${INPUT_REVIEWDOG_FLAGS} in the reviewdog invocation to prevent metacharacter injection from the reviewdog_flags input. Removed the associated shellcheck disable comments (SC2046, SC2086) that were suppressing warnings about these unquoted expansions.

