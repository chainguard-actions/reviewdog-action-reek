<!-- markdownlint-disable -->

# Hardening Report: reviewdog--action-reek/v1.21.0

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `2`

Action **reviewdog--action-reek/v1.21.0** was hardened automatically. 1 finding(s) were identified and resolved across 1 iteration(s).

## Findings Fixed

### unsafe-shell (severity: high)

script.sh (run by the action's composite step) downloads a remote script and pipes it straight into a shell: `curl -sfL https://raw.githubusercontent.com/reviewdog/reviewdog/fd59714416d6d9a1c0692d872e38e7f8448df4fc/install.sh | sh -s -- -b "${TEMP_PATH}" "${REVIEWDOG_VERSION}"`. The URL is pinned to a commit, but the downloaded content runs without being saved and checked first. Download install.sh to a file, check its checksum, then run it as a separate step.

Locations:

- `script.sh:15`

## Iteration Notes

### Iteration 1

**Fixes applied:** unsafe-shell

**Notes:**

script.sh no longer pipes the installer into a shell. It downloads the commit-pinned reviewdog install.sh to a temp file and stops with an error if the download fails or the file is empty or has no shebang line. It then runs the file with `sh "$file" -b "$TEMP_PATH" "$REVIEWDOG_VERSION"`; the `-s --` is dropped so the script gets `-b` as $1, and the file is deleted afterwards. There is no sha256 check, because I had no way to fetch the file and get its real hash, and I did not want to invent one. The URL is pinned to a commit, so its content should not change. Nothing has been run or tested.

