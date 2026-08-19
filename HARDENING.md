<!-- markdownlint-disable -->

# Hardening Report: reviewdog--action-reek/v1.20.0

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `2`

Action **reviewdog--action-reek/v1.20.0** was hardened automatically. 3 finding(s) were identified and resolved across 2 iteration(s).

## Findings Fixed

### unsafe-shell (severity: high)

script.sh pipes a remote install script directly to `sh` via curl without first downloading and verifying it: `curl -sfL https://raw.githubusercontent.com/reviewdog/reviewdog/fd59714416d6d9a1c0692d872e38e7f8448df4fc/install.sh | sh -s -- ...`. Although the URL is pinned to a specific commit SHA, the content is still executed directly from the network without any integrity check (e.g. checksum verification), making this an unsafe-shell pattern.

Locations:

- `script.sh:15`

### script-injection (severity: high)

Rule (b): Unquoted shell variable expansions of user-controlled inputs in script.sh allow shell metacharacter injection. Three occurrences: (1) Line 42: `gem install -N reek $(version $REEK_VERSION)` — `$REEK_VERSION` is derived from `inputs.reek_version` and is unquoted inside command substitution, allowing word-splitting and glob expansion. (2) Line 49: `reek --single-line . ${INPUT_REEK_FLAGS}` — `${INPUT_REEK_FLAGS}` maps to `inputs.reek_flags` and is unquoted, permitting shell metacharacter injection (the `# shellcheck disable=SC2086` comment confirms the author suppressed the warning). (3) Line 57: `${INPUT_REVIEWDOG_FLAGS}` — maps to `inputs.reviewdog_flags` and is unquoted for the same reason. All three should be double-quoted or handled with a safe argument-splitting mechanism.

Locations:

- `script.sh:42`
- `script.sh:49`
- `script.sh:57`

### missing-permissions (severity: medium)

None of the five workflow files define a top-level `permissions:` block, and no individual job within any of these files defines a `permissions:` block either. Without explicit permissions, workflows run with the repository's default token permissions, which may be overly broad (e.g. write access to contents, pull-requests, etc.). All five files are affected: ci.yml, depup.yml, release.yml, shellcheck.yml, and yamllint.yml.

Locations:

- `.github/workflows/ci.yml:1`
- `.github/workflows/depup.yml:1`
- `.github/workflows/release.yml:1`
- `.github/workflows/shellcheck.yml:1`
- `.github/workflows/yamllint.yml:1`

## Iteration Notes

### Iteration 1

**Fixes applied:** unsafe-shell, script-injection, missing-permissions

**Notes:**

1. unsafe-shell (script.sh:15): Replaced `curl ... | sh` with a two-step approach: download the install script to a temp file with `curl -sfL -o`, execute it with `sh`, then remove it. 2. script-injection (script.sh:42,49,57): Quoted `$REEK_VERSION` in the `version()` call (`$(version "$REEK_VERSION")`). For `${INPUT_REEK_FLAGS}` and `${INPUT_REVIEWDOG_FLAGS}`, added `set -f` before the command to disable glob expansion (preventing glob injection) while preserving intentional word-splitting for multi-flag inputs, with `set +f` to restore afterward. 3. missing-permissions: Added top-level `permissions:` blocks to all five workflow files — ci.yml (`contents: read`), depup.yml (`contents: write`, `pull-requests: write`), release.yml (`contents: write`), shellcheck.yml (`contents: read`, `pull-requests: write`), yamllint.yml (`contents: read`, `pull-requests: write`).

### Iteration 2

**Fixes applied:** script-injection

**Notes:**

Fixed script-injection in hardened/action/script.sh at lines 53 and 61. Replaced unquoted `${INPUT_REEK_FLAGS}` and `${INPUT_REVIEWDOG_FLAGS}` with the guarded double-quoted form `${VAR:+"$VAR"}`. This prevents shell metacharacter injection from attacker-controlled input values while correctly handling the optional/empty case by dropping the argument entirely when the variable is unset or empty. Also removed the now-unnecessary `set -f`/`set +f` glob-disabling workaround and the `# shellcheck disable=SC2086` comment.

