#!/usr/bin/env bash
# Run ON the Ubuntu A10 GPU VM after first SSH.
# Installs NVIDIA drivers (if needed), Ollama bound to localhost, and a coding model.
# Does not touch Oracle billing, Upgrade, or payment methods.
set -euo pipefail

MODEL="${1:-qwen2.5-coder:32b}"

echo "==> Checking NVIDIA GPU"
if ! command -v nvidia-smi >/dev/null 2>&1; then
  echo "nvidia-smi not found. Installing Ubuntu drivers (reboot may be required)..."
  sudo apt-get update -y
  sudo apt-get install -y ubuntu-drivers-common
  sudo ubuntu-drivers autoinstall || true
  if ! command -v nvidia-smi >/dev/null 2>&1; then
    echo "Drivers installed or pending. Reboot the VM, SSH back, and re-run this script."
    echo "  sudo reboot"
    exit 0
  fi
fi
nvidia-smi

echo "==> Installing Ollama"
curl -fsSL https://ollama.com/install.sh | sh
sudo systemctl enable --now ollama

echo "==> Binding Ollama to 127.0.0.1 only (use SSH tunnel from your PC)"
sudo mkdir -p /etc/systemd/system/ollama.service.d
sudo tee /etc/systemd/system/ollama.service.d/override.conf >/dev/null <<'EOF'
[Service]
Environment="OLLAMA_HOST=127.0.0.1:11434"
EOF
sudo systemctl daemon-reload
sudo systemctl restart ollama
sleep 2

echo "==> Pulling model: $MODEL"
echo "    (qwen2.5-coder:32b Q4 fits ~24GB A10 VRAM; 70B Q4 will not)"
ollama pull "$MODEL"

echo
echo "Ready."
echo "From your PC (with this repo):"
echo "  ./bin/gpu tunnel"
echo "Then point Hermes / any OpenAI-compatible client at:"
echo "  base_url: http://127.0.0.1:11434/v1"
echo "  model:    $MODEL"
echo
echo "When finished working: ./bin/gpu stop"
echo "Before Free Trial ends: ./bin/gpu kill"
