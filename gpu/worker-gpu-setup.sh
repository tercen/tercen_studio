#!/bin/bash
# Boot-time GPU enablement for the tercen-worker container (Fedora-based image).
# Runs as root BEFORE podman-init.sh (see docker-compose.gpu.yaml).
# Validated end-to-end on GCP (T4, driver 580, toolkit 1.20) 2026-08-26.
set -e

# 1. NVIDIA container toolkit (runtime + CDI generator)
if ! command -v nvidia-ctk >/dev/null 2>&1; then
  curl -fsSL -o /etc/yum.repos.d/nvidia-ctk.repo \
    https://nvidia.github.io/libnvidia-container/stable/rpm/nvidia-container-toolkit.repo
  dnf install -y -q nvidia-container-toolkit
fi

# 2. CDI spec for the GPUs docker injected into this container
mkdir -p /etc/cdi
nvidia-ctk cdi generate --output=/etc/cdi/nvidia.yaml

# 3. Register the runtime via a drop-in — podman-init.sh REWRITES
#    /etc/containers/containers.conf, so the main file cannot be used.
#    This is what makes ExeRunner.hasGpuCapability() true, which in turn
#    makes the worker add --gpus=all for operators with the "gpu" capability.
mkdir -p /etc/containers/containers.conf.d
printf '[engine.runtimes]\nnvidia = ["/usr/bin/nvidia-container-runtime"]\n' \
  > /etc/containers/containers.conf.d/90-nvidia.conf

# 4. Some code paths (dockerApi in worker task isolates) fall back to the
#    docker default socket path — point it at podman.
ln -sf /run/podman/podman.sock /run/docker.sock

echo "[gpu-setup] nvidia runtime registered for podman"
