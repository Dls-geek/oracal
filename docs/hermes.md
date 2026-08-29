# Hermes (and other agents) + Ollama via oci-watchdog

Keep your real Hermes config on your machine. **Do not commit** `~/.hermes/config.yaml` or API keys.

## Prerequisites

1. Instance OCID in `.env.oci`
2. `./bin/watchdog start`
3. Ollama on the VM (`scripts/setup-ollama.sh`)
4. `./bin/watchdog tunnel` left running

## Minimal Hermes model block

```yaml
# Example only — do NOT commit your real config
model:
  default: qwen2.5-coder:14b   # use :32b on A10 if you have one
  provider: custom
  base_url: http://127.0.0.1:11434/v1
```

## Custom provider entry

```yaml
custom_providers:
  - name: oci-watchdog
    base_url: http://127.0.0.1:11434/v1
    model: qwen2.5-coder:14b
    models:
      qwen2.5-coder:14b: {}
      qwen2.5-coder:32b: {}
```

Keep a free/cloud provider as fallback when the VM is stopped.

## curl smoke test

```bash
curl http://127.0.0.1:11434/v1/models
curl http://127.0.0.1:11434/v1/chat/completions \
  -H 'Content-Type: application/json' \
  -d '{
    "model": "qwen2.5-coder:14b",
    "messages": [{"role": "user", "content": "Say hi in one sentence."}]
  }'
```

## Work loop

```text
./bin/watchdog start → ./bin/watchdog tunnel → Hermes → Ctrl+C → ./bin/watchdog stop
```

Before Free Trial ends: `./bin/watchdog kill` (type `DELETE`).
