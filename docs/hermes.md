# Hermes (and other agents) + Ollama on A10

Keep your real Hermes config on your machine. **Do not commit** `~/.hermes/config.yaml` or API keys.

## Prerequisites

1. A10 instance created and `INSTANCE_OCID` set in `.env.oci`
2. `./bin/gpu start`
3. Ollama installed on the VM (`scripts/setup-ollama-gpu.sh`)
4. `./bin/gpu tunnel` left running in a terminal

## Minimal Hermes model block

```yaml
model:
  default: qwen2.5-coder:32b
  provider: custom
  base_url: http://127.0.0.1:11434/v1
```

## Custom provider entry (alongside other providers)

```yaml
custom_providers:
  - name: oci-a10
    base_url: http://127.0.0.1:11434/v1
    model: qwen2.5-coder:32b
    models:
      qwen2.5-coder:32b: {}
```

Switch Hermes to that provider/model when the tunnel is up. Keep a free/cloud provider as fallback when the GPU is stopped.

## curl smoke test

```bash
curl http://127.0.0.1:11434/v1/models
curl http://127.0.0.1:11434/v1/chat/completions \
  -H 'Content-Type: application/json' \
  -d '{
    "model": "qwen2.5-coder:32b",
    "messages": [{"role": "user", "content": "Say hi in one sentence."}]
  }'
```

## Work loop

```text
./bin/gpu start  →  ./bin/gpu tunnel  →  Hermes  →  Ctrl+C tunnel  →  ./bin/gpu stop
```

Before Free Trial ends: `./bin/gpu kill` (type `DELETE`).
