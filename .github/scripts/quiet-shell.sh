#!/usr/bin/env bash
# Custom "shell" for converted jobs (defaults.run.shell: quiet-shell {0}).
# GitHub writes each run: block to a file and calls this with its path. The
# step runs exactly like the default bash shell (-e -o pipefail), but all of
# its output goes to the private log instead of the public Actions log.
set -u
out="$RUNNER_TEMP/out"; mkdir -p "$out"
export GITHUB_STEP_SUMMARY="$out/summary.md"   # summaries are public too
{ echo; echo "===== step: ${GITHUB_ACTION:-?}  $(date -u +%T)"; } >> "$out/run.log"
start=$(date +%s)
bash --noprofile --norc -eo pipefail "$1" >> "$out/run.log" 2>&1
rc=$?
echo "exit=$rc  duration=$(( $(date +%s) - start ))s  (output kept privately)"
exit $rc
