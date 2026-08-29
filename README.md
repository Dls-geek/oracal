# oci-watchdog

**Guard your Oracle Cloud Free Trial credits.**  
Start the VM when you work. Stop when you stop. Kill it before the trial ends — so nothing expensive is left running.

```text
  work time  →  ./bin/watchdog start  →  tunnel  →  code
  idle       →  ./bin/watchdog stop
  trial end  →  ./bin/watchdog kill   (type DELETE)
```

**Credits only — never Upgrade, never add a payment method.**  
This CLI never calls billing upgrade APIs.

> Oracle allows **one Free Trial / Always Free account per person**. This project does not help create extra accounts.

## What it watches

| Threat | Watchdog action |
| --- | --- |
| Leaving compute RUNNING overnight | `stop` — hourly burn pauses |
| Trial ends with a leftover VM/GPU | `kill` — terminate + delete boot volume |
| Blind to days/credits left | `status` / `credits` — trial clock + estimate |
| Home region only (no extra regions on Free Trial) | Run your own model via Ollama on that region |

### Shape reality (important)

Many Free Trial tenancies have **`gpu-a10-count = 0`**, so **`VM.GPU.A10.1` will not appear** and cannot be created without leaving Free Tier.

| Shape | Free Trial? | Notes |
| --- | --- | --- |
| **`VM.Standard.A1.Flex`** (Ampere) | Usually yes | Prefer **4 OCPU / 24 GB**; CPU models (`qwen2.5-coder:14b`) |
| **`VM.GPU.A10.1`** | Often **no** (limit 0) | Only if your limits allow — do **not** Upgrade just to unlock it |

Check limits: Console → Governance → Limits, or `oci limits value list --service-name compute ...`

## Quick start

### 1. Clone and configure

```bash
git clone https://github.com/Dls-geek/oci-watchdog.git
cd oci-watchdog
cp .env.oci.example .env.oci
```

### 2. OCI CLI + API signing key (not a payment card)

```bash
# https://docs.oracle.com/en-us/iaas/Content/API/SDKDocs/cliinstall.htm
bash -c "$(curl -L https://raw.githubusercontent.com/oracle/oci-cli/master/scripts/install/install.sh)"
oci setup config
```

Console: **Profile → User settings → API keys → Add API key** (IAM signing key).

Fill `TENANCY_OCID`, `COMPARTMENT_OCID`, `HOME_REGION`, and `TRIAL_START` in `.env.oci`.

### 3. Create the watched instance (home region only)

1. [cloud.oracle.com](https://cloud.oracle.com) → region = **home region**
2. **Compute → Instances → Create instance**
3. Shape:
   - **Ampere** → **`VM.Standard.A1.Flex`** (4 OCPU / 24 GB) — Free Trial path  
   - or **Specialty → GPU → `VM.GPU.A10.1`** only if it appears without Upgrade
4. Image: **Ubuntu 22.04/24.04** (use **aarch64** for A1)
5. SSH public key; public subnet + public IP; **SSH 22 from your IP only** — never open **11434**
6. Boot ~100–150 GB for models
7. Create → copy **Instance OCID** into `.env.oci`

### 4. Daily loop

```bash
./bin/watchdog start
./bin/watchdog tunnel          # leave open
# Hermes / curl → http://127.0.0.1:11434/v1
# Ctrl+C tunnel when done
./bin/watchdog stop
```

Before trial end:

```bash
./bin/watchdog kill            # type DELETE
```

(`./bin/gpu` is a symlink to `watchdog` for older docs.)

### 5. Bootstrap Ollama on the VM

```bash
./bin/watchdog ssh
curl -fsSL https://raw.githubusercontent.com/Dls-geek/oci-watchdog/main/scripts/setup-ollama.sh | bash
# or: bash scripts/setup-ollama.sh
```

## CLI reference

| Command | What it does |
| --- | --- |
| `./bin/watchdog start` | START, wait RUNNING, print IP + credit/time |
| `./bin/watchdog stop` | STOP — pause hourly burn |
| `./bin/watchdog status` | State, IP, trial clock, credit estimate |
| `./bin/watchdog credits` | Trial clock + credits only |
| `./bin/watchdog ssh` | SSH |
| `./bin/watchdog tunnel` | `localhost:11434` → VM Ollama |
| `./bin/watchdog kill` | Terminate + delete boot volume |

## Hermes / OpenAI-compatible clients

See [docs/hermes.md](docs/hermes.md).

## Safety checklist

- [ ] Stay on **Free Tier / Promo** — no Upgrade, no new payment method
- [ ] One trial per person (Oracle policy)
- [ ] Home region only
- [ ] `stop` when idle; `kill` before trial ends
- [ ] Never commit `.env.oci`, `*.pem`, or private SSH keys
- [ ] Do not expose Ollama (`11434`) publicly

## License

MIT — see [LICENSE](LICENSE).

## Disclaimer

Unofficial. Not affiliated with Oracle. Limits, pricing, and Free Tier rules change; verify in your Console. You are responsible for your tenancy and for not upgrading if you want zero card charges.
