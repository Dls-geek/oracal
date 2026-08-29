#!/usr/bin/env bash
# Thin wrapper — prefer scripts/setup-ollama-gpu.sh on A10 VMs.
exec "$(cd "$(dirname "$0")" && pwd)/scripts/setup-ollama-gpu.sh" "$@"
