#!/usr/bin/env bash
# Pushes run.log plus any report files to the branch logs/<job> of the
# PRIVATE repo (one commit, overwritten every run). Nothing is printed except
# a short status line, so no data ends up in the public Actions log.
# Usage: save-logs.sh <owner/private-repo> <job-name> [report files...]
set -uo pipefail
repo="$1"; job="$2"; shift 2
dir="$RUNNER_TEMP/logs-$job"
rm -rf "$dir"; mkdir -p "$dir"
for f in run.log summary.md; do [ -f "$RUNNER_TEMP/out/$f" ] && cp "$RUNNER_TEMP/out/$f" "$dir/"; done
for f in "$@"; do [ -f "$f" ] && cp "$f" "$dir/"; done
{
  echo "run: ${GITHUB_SERVER_URL}/${GITHUB_REPOSITORY}/actions/runs/${GITHUB_RUN_ID}"
  echo "event: ${GITHUB_EVENT_NAME}"
  echo "time: $(date -u +%FT%TZ)"
} > "$dir/RUN_INFO.txt"
cd "$dir"
git init -q -b "logs/$job"
git config user.name "runner-logs"
git config user.email "actions@users.noreply.github.com"
git add -A
git commit -qm "$job $(date -u +%FT%TZ)"
if git push -qf "https://x-access-token:${PRIVATE_REPO_TOKEN}@github.com/${repo}.git" "HEAD:logs/$job" >/dev/null 2>&1; then
  echo "Saved log and reports to ${repo} branch logs/$job"
else
  echo "Could not save logs to ${repo} (check the PRIVATE_REPO_TOKEN secret)"
fi
