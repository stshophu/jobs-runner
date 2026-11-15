#!/usr/bin/env bash
# Copies finished feed files from the private code checkout (src/) into the
# PUBLIC feed host stshophu/siebentaschen-feed, so the existing raw URLs
# (e.g. raw.githubusercontent.com/stshophu/siebentaschen-feed/main/google_feed.xml)
# keep working. Usage: publish-feeds.sh <file> [file...]   (run from src/)
set -uo pipefail
dest="$RUNNER_TEMP/feed-host"
url="https://x-access-token:${PRIVATE_REPO_TOKEN}@github.com/stshophu/siebentaschen-feed.git"
for attempt in 1 2 3 4; do
  rm -rf "$dest"
  git clone -q --depth 1 "$url" "$dest" >/dev/null 2>&1 || { echo "clone failed (attempt $attempt)"; sleep 10; continue; }
  for f in "$@"; do [ -f "$f" ] && cp "$f" "$dest/"; done
  cd "$dest"
  git config user.name "github-actions[bot]"
  git config user.email "github-actions[bot]@users.noreply.github.com"
  git add -A
  if git diff --quiet --cached; then echo "feed files unchanged"; exit 0; fi
  git commit -qm "Update feed $(date -u +%FT%TZ)"
  if git push -q origin HEAD:main >/dev/null 2>&1; then echo "published: $*"; exit 0; fi
  echo "push raced with another feed job, retrying ($attempt)"; cd - >/dev/null; sleep $((attempt * 7))
done
echo "could not publish feed files"; exit 1
