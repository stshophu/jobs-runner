# viterbo-runner

Public "runner" repo for Siebentaschen's scheduled jobs. It contains **only
workflow files**. Each workflow checks out a **private** repo with the
`PRIVATE_REPO_TOKEN` secret and runs its code here, because GitHub Actions
minutes are free in public repos.

## Job groups

| Prefix | Private code repo | Switched on by variable |
|---|---|---|
| (none) Stork, Viterbo, VAITTO L feed, BUYMA | stork-sync, viterbo-sync, vaitto-loxuno-feed, connector | `RUNNER_ENABLED` |
| `pf-` | product-feed | `PF_ENABLED` |
| `ps-` | prod_synch | `PS_ENABLED` |
| `rx-` | rewix-shopify-sync | `RX_ENABLED` |
| `ssp-` | supplier-sync-portfolio | `SSP_ENABLED` |
| `sf-` | siebentaschen-feed-src (feeds are published to the public repo siebentaschen-feed) | `SF_ENABLED` |

Set a variable to `false` to pause that group. Secrets of group XX are named
`XX_<original name>` (copied automatically by the migration).

Secrets for the group without prefix (enter by hand): `STORK_SYNC_CLIENT_ID`,
`STORK_SYNC_CLIENT_SECRET`, `VITERBO_SHOPIFY_DOMAIN`, `VITERBO_SHOPIFY_TOKEN`,
`VITERBO_FEED_URL` (= `SHOPIFY_DOMAIN`, `SHOPIFY_TOKEN`, `VITERBO_FEED_URL` in
viterbo-sync), `LOXUNO_KAKCA_FEED`, `LOXUNO_PARALLEL_FEED`, `LOXUNO_EGAZI_FEED`,
`SHOPIFY_STORE_DOMAIN`, `SHOPIFY_ADMIN_TOKEN`, `BUYMA_ACCESS_TOKEN`; variables
`VITERBO_IMPORT_ENABLED`, `VITERBO_DAILY_CAP`.

## Nothing sensitive in the public logs

- Every `run:` step goes through `quiet-shell` (`.github/scripts/quiet-shell.sh`)
  or `quiet-run.sh`: the public log only shows exit code and duration.
- The full output, job summary and any report CSV go to the **private** repo,
  branch `logs/<job>` (overwritten each run).
- No artifacts are uploaded here; keys live only in this repo's Secrets.

**Rule when adding jobs:** keep `defaults.run.shell: quiet-shell {0}` and never
use `actions/upload-artifact` in this repo.

## Token (`PRIVATE_REPO_TOKEN`)

GitHub → Settings → Developer settings → Fine-grained tokens → Generate:
resource owner `stshophu`, **All repositories**, repository permissions:
Contents, Secrets, Variables, Actions, Workflows, Issues — all **Read and write**.
After the migration you can remove Secrets, Variables, Actions and Workflows
again (the jobs only need Contents + Issues).

## One-off migration

1. Add the token above as secret `PRIVATE_REPO_TOKEN` here.
2. Actions → **One-off — migrate repos into this runner** → Run workflow.
3. Rename `siebentaschen-feed` → `siebentaschen-feed-src`, make it private,
   create a new **public** repo `siebentaschen-feed` (tick "Add a README"),
   then run **One-off — finish feed move**.
4. Make private: product-feed, prod_synch, rewix-shopify-sync,
   supplier-sync-portfolio, siebentaschen-feed-src, allegro-api.
