# Tercen Studio

A local Tercen development environment, running the same released images and
architecture as production:

| Service | Image | Role |
|---|---|---|
| `tercen` | `tercen/tercen:1.1.8` | main application — manages its own `sarno` table engine via internal podman |
| `tercen-worker` | `tercen/tercen:1.1.8` | task execution — runs operator containers via its own internal podman |
| `scheduler` | `tercen/ha-scheduler:0.34.9` | task dispatch |
| `sarno` | `tercen/sarno:1.2.5` | table engine — not a compose service; `tercen` starts it in its own podman, pinned by `TERCEN_SARNO_IMAGE` |
| `postgres` | `postgres:16` | document storage (the production backend since the 1.0 line) |
| `redis` | `redis:7-alpine` | queues and caching |
| `tercen-studio` | RStudio (R 4.4) | **opt-in**, `--profile rstudio` — see [RStudio is no longer in the default stack](#rstudio-is-no-longer-in-the-default-stack) |
| `code-server` | VS Code (Python) | optional, `--profile python` |

# Setup

Install [docker-compose](https://docs.docker.com/compose/install/), then:

```bash
git clone https://github.com/tercen/tercen_studio.git
cd tercen_studio

# optional but recommended: lets Tercen install operators from private
# GitHub repositories and pull private ghcr.io images.
# Use a CLASSIC personal access token with `repo` scope
# (fine-grained github_pat_… tokens are not accepted by the git zipball endpoint).
export GITHUB_TOKEN=ghp_your_token_here

docker compose up -d
```

- Tercen: [http://127.0.0.1:5402](http://127.0.0.1:5402) — admin / admin
- RStudio (optional): `docker compose --profile rstudio up -d` → [http://127.0.0.1:8787](http://127.0.0.1:8787) — rstudio / tercen
- VS Code (optional): `docker compose --profile python up -d` → [http://127.0.0.1:8443](http://127.0.0.1:8443)

Ports bind to **127.0.0.1 only**. The studio has a fixed admin/admin login and
runs an older RStudio, so it should not be reachable from the network by
default. To expose it deliberately — a shared dev box, or a GPU VM you reach
over SSH — set `BIND_ADDR`:

```bash
BIND_ADDR=0.0.0.0 docker compose up -d   # or a specific interface address
```

Prefer an SSH tunnel (`ssh -L 5402:127.0.0.1:5402 <host>`) over `0.0.0.0` where
you can.

# The operator dev loop

1. In Tercen (`:5402`): create a project, import your CSV, add a data step and
   set the crosstab projection.
2. Iterate on `main.R` in **the operator's own image** — the environment CI and
   production actually use:

   ```bash
   docker run --rm -v "$PWD:/operator" -w /operator \
     --network tercen_studio_tercen \
     tercen/runtime-r44-minimal:4.4.3-2 \
     R --no-save -f main.R --args --taskId=<id> --serviceUri=http://tercen:5400/api/v1/
   ```
3. Tercen can also install and run the operator for real (git install +
   container execution), exactly like production — including private repos and
   images when `GITHUB_TOKEN` is set.

# RStudio is no longer in the default stack

`docker compose up -d` no longer starts RStudio. It is still available behind
`--profile rstudio`, but it should not be used to produce results that are
compared against CI.

Its R is 4.4.3 — the same *version* operators use — but nothing else matches:

| | RStudio | `runtime-r44-minimal` (operator Tier 1/2) |
|---|---|---|
| OS / libc | Ubuntu 24.04, glibc | Alpine, **musl** |
| BLAS/LAPACK | OpenBLAS 0.3.26 | **reference `libRlapack`** |
| Packages | 190 | 36 |

OpenBLAS and reference LAPACK do not agree bit-for-bit on `svd`, `lm`, `prcomp`
or matrix multiplication. The differences are small, and exactly large enough to
break an exact-match golden test — so the one job RStudio was kept for,
generating expected output, is the job it is least suited to.

Prototype and generate golden output in the operator's own image instead: that
is CI-exact by construction rather than by resemblance.

# Update

Versions are pinned in `docker-compose.yaml` (`tercen/tercen`, `tercen/ha-scheduler`,
`TERCEN_SARNO_IMAGE`). To update, bump those pins to the currently deployed
production versions and:

Production's own pins are the source of truth: `tercen` and `ha-scheduler` are
the image tags on the `tercen-prod` deployments, and sarno is
`tercen.sarno.image` in the `tercen-config` ConfigMap — it is a config value,
not a pod image, so it does not show up in a `kubectl get deploy` listing.

```bash
docker compose pull
docker compose up -d
```

## Upgrading from the pre-0.17 studio

The architecture changed (redis + scheduler + separate worker are new; the
`sarno` and `runtime-docker` services are gone — both now run inside the
tercen containers). Start fresh:

```bash
docker compose down -v   # removes old volumes (postgres data included!)
docker compose up -d
```

# GPU operator development

With an NVIDIA GPU on the host (driver + `nvidia-container-toolkit` configured
for docker), start the studio with the GPU overlay:

```bash
docker compose -f docker-compose.yaml -f docker-compose.gpu.yaml up -d
```

Operators declaring `"capabilities": ["gpu"]` in `operator.json` are then run
with `--gpus=all` automatically. Validated end-to-end 2026-08-26 (GCP T4). To
verify a setup, install and run
[gpu_smoke_operator](https://github.com/tercen/gpu_smoke_operator) — it prints
the GPUs visible inside the operator container.

# Notes

- The Tercen web UI ships with the same anonymous usage analytics as
  tercen.com (Google Tag Manager). It fires only when the UI is opened in a
  browser; block `googletagmanager.com` (or use any ad-blocker) to opt out.

- The `tercen` and `tercen-worker` containers are `privileged`: they run
  podman inside to manage sarno and operator containers (same as production
  pods).
- Operator/table data lives in the `tercen-data` volume, shared between main
  and worker.
- GPU development: see `docker/` and the commented nvidia sections of previous
  revisions; the `code-server`/RStudio images can be swapped for the GPU
  variants.
