#!/bin/bash
# Sourced (". scripts/load-project-env-linux.sh"): loads project.env (PROJECT_NAME, VERSION,
# SOLUTION_FILE, ...) into the environment and sets PLATFORM_TOKEN / ARCH / ROOT_DIR. Linux and WSL are
# the same platform token: "linux".
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
export ROOT_DIR
set -a
. "$ROOT_DIR/project.env"
set +a
PLATFORM_TOKEN=linux
case "$(uname -m)" in aarch64|arm64) ARCH=arm64 ;; *) ARCH=x64 ;; esac
export PLATFORM_TOKEN ARCH
