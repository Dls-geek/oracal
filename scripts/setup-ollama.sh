#!/usr/bin/env bash
# Run ON the Ubuntu VM after first SSH (A10 GPU or Ampere A1 CPU).
# Installs Ollama on localhost only. Does not touch Oracle billing.
set -euo pipefail

# A10 (24GB): qwen2.5-coder:32b | Ampere A1 CPU: qwen2.5-coder:14b (or smaller)
MODEL="${1:-}"

echo "==> Checking for NVIDIA GPU"
HAS_GPU=0
if command -v nvidia-smi >/dev/null 2>&1 || lspci 2>/dev/null | grep -qi nvidia; then
  if ! command -v nvidia-smi >/dev/null 2>&1; then
    echo "NVIDIA device present but nvidia-smi missing. Installing drivers..."
    sudo apt-get update -y
    sudo apt-get install -y ubuntu-drivers-common
    sudo ubuntu-drivers autoinstall || true
    if ! command -v nvidia-smi >/dev/null 2>&1; then
      echo "Reboot the VM, SSH back, and re-run this script."
      echo "  sudo reboot"
      exit 0
    fi
  fi
  nvidia-smi
  HAS_GPU=1
  MODEL="${MODEL:-qwen2.5-coder:32b}"
else
  echo "No NVIDIA GPU detected — CPU/Ampere path (slower; use a smaller model)."
  MODEL="${MODEL:-qwen2.5-coder:14b}"
fi

echo "==> Installing Ollama"
curl -fsSL https://ollama.com/install.sh | sh
sudo systemctl enable --now ollama

echo "==> Binding Ollama to 127.0.0.1 only (SSH tunnel from your PC)"
sudo mkdir -p /etc/systemd/system/ollama.service.d
sudo tee /etc/systemd/system/ollama.service.d/override.conf >/dev/null <<'EOF'
[Service]
Environment="OLLAMA_HOST=127.0.0.1:11434"
EOF
sudo systemctl daemon-reload
sudo systemctl restart ollama
sleep 2

echo "==> Pulling model: $MODEL"
ollama pull "$MODEL"

echo
echo "Ready (GPU=$HAS_GPU)."
echo "From your PC:"
echo "  ./bin/watchdog tunnel"
echo "  base_url: http://127.0.0.1:11434/v1"
echo "  model:    $MODEL"
echo
echo "When finished: ./bin/watchdog stop"
echo "Before Free Trial ends: ./bin/watchdog kill"
