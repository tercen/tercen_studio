# Tercen Studio

A local Tercen development environment, running the same released images and
architecture as production:

| Service | Image | Role |
|---|---|---|
| `tercen` | `tercen/tercen:1.0.26` | main application — manages its own `sarno` table engine via internal podman |
| `tercen-worker` | `tercen/tercen:1.0.26` | task execution — runs operator containers via its own internal podman |
| `scheduler` | `tercen/ha-scheduler:0.34.9` | task dispatch |
| `postgres` | `postgres:16` | document storage (the production backend since the 1.0 line) |
| `couchdb` / `redis` | `couchdb:3.5.1` / `redis:7` | legacy storage, kept as production does / queues |
| `tercen-studio` | RStudio (R 4.4) | operator development |
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
- RStudio: [http://127.0.0.1:8787](http://127.0.0.1:8787) — rstudio / tercen
- VS Code (optional): `docker compose --profile python up -d` → [http://127.0.0.1:8443](http://127.0.0.1:8443)

# The operator dev loop

1. In Tercen (`:5402`): create a project, import your CSV, add a data step and
   set the crosstab projection.
2. In RStudio (`:8787`): clone your operator, `renv::restore()`, and run
   `main.R` in dev mode against that step — results are saved back to the step.
3. Tercen can also install and run the operator for real (git install +
   container execution), exactly like production — including private repos and
   images when `GITHUB_TOKEN` is set.

# Update

Versions are pinned in `docker-compose.yaml` (`tercen/tercen`, `tercen/ha-scheduler`,
`TERCEN_SARNO_IMAGE`). To update, bump those pins to the currently deployed
production versions and:

```bash
docker compose pull
docker compose up -d
```

## Upgrading from the pre-0.17 studio

The architecture changed (redis + scheduler + separate worker are new; the
`sarno` and `runtime-docker` services are gone — both now run inside the
tercen containers). Start fresh:

```bash
docker compose down -v   # removes old volumes (postgres + couchdb data included!)
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
