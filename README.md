# viterbo-runner

Public "runner" repo for Siebentaschen's scheduled jobs. It contains **only
workflow files**. Each workflow checks out a **private** repo with the
`PRIVATE_REPO_TOKEN` secret and runs its code here, because GitHub Actions
minutes are free in public repos.

| Workflow | Private code | Schedule |
|---|---|---|
| Stork sync | stork-sync | every 30 min |
| Viterbo — Hourly Stock & Price Refresh | viterbo-sync | hourly :45 |
| Viterbo — Daily Import | viterbo-sync | daily 04:10 UTC |
| VAITTO Loxuno feed | vaitto-loxuno-feed | hourly :00 |
| BUYMA nightly stock reconcile | connector | daily 02:17 UTC |
| BUYMA sale tags | connector | 9 + 24 Nov |
| BUYMA republish by tag | connector | manual / `.github/republish-run` |
| BUYMA category dry-run | connector | manual |
| Keepalive | – | monthly (stops GitHub's 60-day schedule shutoff) |

## Nothing sensitive in the public logs

Everything in this repo's Actions tab is visible to anyone. So:

- Every job runs through `.github/scripts/quiet-run.sh`: the public log only
  shows the exit code, number of log lines and duration.
- The full output plus any report CSV (Stork wholesale prices, BUYMA reports …)
  is pushed to the **private** repo, branch `logs/<job>` (overwritten each run).
  To read a log: open the private repo → switch branch → `logs/<job>`.
- No artifacts are uploaded here. Keys live only in this repo's Secrets.

**Rule when adding jobs:** never `echo`/print data in a step outside
`quiet-run.sh`, and never use `actions/upload-artifact` in this repo.

## Secrets (Settings → Secrets and variables → Actions)

| Secret | Used by |
|---|---|
| `PRIVATE_REPO_TOKEN` | all — fine-grained token, see below |
| `STORK_SYNC_CLIENT_ID`, `STORK_SYNC_CLIENT_SECRET` | Stork sync |
| `VITERBO_SHOPIFY_DOMAIN`, `VITERBO_SHOPIFY_TOKEN`, `VITERBO_FEED_URL` | Viterbo (= `SHOPIFY_DOMAIN`, `SHOPIFY_TOKEN`, `VITERBO_FEED_URL` in viterbo-sync) |
| `LOXUNO_KAKCA_FEED`, `LOXUNO_PARALLEL_FEED`, `LOXUNO_EGAZI_FEED` | VAITTO Loxuno feed |
| `SHOPIFY_STORE_DOMAIN`, `SHOPIFY_ADMIN_TOKEN`, `BUYMA_ACCESS_TOKEN` | BUYMA jobs (connector) |

Variables (same page, "Variables" tab): `VITERBO_IMPORT_ENABLED`, `VITERBO_DAILY_CAP`.

`PRIVATE_REPO_TOKEN`: GitHub → Settings → Developer settings → Fine-grained
tokens → new token, resource owner `stshophu`, **Only select repositories**:
connector, stork-sync, viterbo-sync, vaitto-loxuno-feed.
Repository permissions: **Contents: Read and write** (needed to save logs, the
BUYMA stock snapshot and the VAITTO feed CSV). Nothing else.

## Switching it on

All jobs stay idle until the repo **variable** `RUNNER_ENABLED` is set to
`true` — add it once the token and secrets above are in. Set it to `false` to
pause everything at once.
