#!/usr/bin/env bash
# Runs a job command without showing its output in the public Actions log.
# Usage: quiet-run.sh <command> [args...]
# The full output goes to $RUNNER_TEMP/out/run.log, which save-logs.sh then
# pushes to a branch of the PRIVATE repo. The public log only shows the exit
# code, line count and duration.
set -uo pipefail
mkdir -p "$RUNNER_TEMP/out"
# Job summaries are public too: redirect them into the private log folder.
export GITHUB_STEP_SUMMARY="$RUNNER_TEMP/out/summary.md"
start=$(date +%s)
"$@" > "$RUNNER_TEMP/out/run.log" 2>&1
rc=$?
echo "exit=$rc  log_lines=$(wc -l < "$RUNNER_TEMP/out/run.log")  duration=$(( $(date +%s) - start ))s"
echo "Full output is kept privately (branch logs/${LOG_JOB:-job} in the private repo)."
exit $rc
