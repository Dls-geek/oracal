# oracal — Oracle Free Trial A10 GPU CLI

Spend your Oracle Cloud **Free Trial promo credits** on a home-region **NVIDIA A10** GPU, run a local coding LLM (Ollama), and control the VM from your laptop.

**Credits only — never Upgrade, never add a payment method.** GPU hours burn credits only while the instance is **RUNNING**. Stop when idle; **kill** (delete) the instance before the trial ends.

> Oracle allows **one Free Trial / Always Free account per person**. This project does not help create extra accounts.

## Why this exists

| Problem | This toolkit |
| --- | --- |
| Free Trial is usually **one home region** (no Hyderabad/Osaka GenAI if home is Singapore) | Run **your own** model on an A10 in the home region |
| Leaving a GPU on 24/7 burns ~\$300 in days | `./bin/gpu start` / `stop` — pay only for work hours |
| Trial ends with a leftover GPU | `./bin/gpu kill` deletes instance + boot volume |
| Hard to see remaining time/money | `./bin/gpu status` / `credits` |

Rough math: A10 ≈ **\$1.50–2.00/hour**. \$300 ≈ **150–200 work hours**, not 30 days of 24/7.

## Quick start

### 1. Clone and configure

```bash
git clone https://github.com/Dls-geek/oracal.git
cd oracal
cp .env.oci.example .env.oci
```

### 2. Install OCI CLI + API signing key (not a payment card)

```bash
# https://docs.oracle.com/en-us/iaas/Content/API/SDKDocs/cliinstall.htm
bash -c "$(curl -L https://raw.githubusercontent.com/oracle/oci-cli/master/scripts/install/install.sh)"
oci setup config
```

In the Console: **Profile → User settings → API keys → Add API key**.  
This is an **IAM signing key**, not a billing card.

Fill `TENANCY_OCID`, `COMPARTMENT_OCID` (often same as tenancy for root), and `HOME_REGION` in `.env.oci`.

### 3. Create the A10 instance (Console, home region only)

1. Open [cloud.oracle.com](https://cloud.oracle.com) and set the region picker to your **home region**.
2. **Compute → Instances → Create instance**.
3. **Change shape** → **Specialty and previous generation** → **GPU** → **`VM.GPU.A10.1`**.
4. If you only see Always Free micros and a banner says *Upgrade*: **do not Upgrade**. Try another availability domain or wait for capacity. If A10 is unavailable on Free Trial in your region, you cannot use this path without leaving Free Trial — this tool will not help you upgrade.
5. Image: **Ubuntu 22.04 or 24.04**.
6. Paste your SSH **public** key.
7. Networking: public subnet + assign public IP. Security list: **SSH (22) from your IP only**. Do **not** open port **11434** to the internet.
8. Boot volume: ~**150 GB** (model weights).
9. Create. Copy the **Instance OCID** into `.env.oci` as `INSTANCE_OCID`.
10. Set `TRIAL_START` from **Billing → Subscription** (promo start date), `SSH_USER=ubuntu`.

### 4. Daily loop

```bash
./bin/gpu start          # wait until RUNNING
./bin/gpu tunnel         # leave this terminal open
# other terminal: work with Hermes / curl against localhost:11434
# Ctrl+C tunnel when done
./bin/gpu stop           # stop GPU billing
```

Before trial end or when credits are near zero:

```bash
./bin/gpu kill           # type DELETE — terminates VM + deletes boot volume
```

### 5. First-time software on the VM

```bash
./bin/gpu ssh
# on the VM:
curl -fsSL https://raw.githubusercontent.com/Dls-geek/oracal/main/scripts/setup-ollama-gpu.sh | bash
# or scp the script and run:
# bash scripts/setup-ollama-gpu.sh
```

Default model: `qwen2.5-coder:32b` (fits A10 24 GB). Do not pull 70B Q4 on a single A10.

## CLI reference

| Command | What it does |
| --- | --- |
| `./bin/gpu start` | START instance, wait RUNNING, print IP + credit/time summary |
| `./bin/gpu stop` | STOP — GPU hours pause; disk remains |
| `./bin/gpu status` | State, IP, trial clock, credit / hours estimate |
| `./bin/gpu credits` | Trial clock + credits only |
| `./bin/gpu ssh` | SSH with your key |
| `./bin/gpu tunnel` | `localhost:11434` → VM Ollama |
| `./bin/gpu kill` | Terminate + delete boot volume (confirm `DELETE`) |

Config file: [`.env.oci.example`](.env.oci.example) → local **`.env.oci`** (gitignored).

This CLI **never** calls Upgrade or payment APIs — only compute actions and read-only usage/cost queries when available.

## Hermes / OpenAI-compatible clients

With `./bin/gpu tunnel` running, any OpenAI-compatible agent can use the GPU model:

```yaml
# Example — do NOT commit your real ~/.hermes/config.yaml
model:
  default: qwen2.5-coder:32b
  provider: custom
  base_url: http://127.0.0.1:11434/v1
```

Or Hermes custom provider style:

```yaml
custom_providers:
  - name: oci-a10
    base_url: http://127.0.0.1:11434/v1
    # no cloud API key — Ollama on localhost via tunnel
    model: qwen2.5-coder:32b
```

See [docs/hermes.md](docs/hermes.md).

## Safety checklist

- [ ] Stay on **Free Tier / Promo**. Do **not** click **Upgrade** or **Add a payment method**.
- [ ] One trial per person (Oracle policy).
- [ ] Home region only — Free Trial usually cannot add Hyderabad/Osaka/etc.
- [ ] `stop` when not working; `kill` before trial ends so no GPU/disk remains.
- [ ] Never commit `.env.oci`, `*.pem`, or SSH private keys.
- [ ] Do not expose Ollama (`11434`) on a public security list.

## Repo layout

```
bin/gpu                      # command center
scripts/setup-ollama-gpu.sh  # run on the Ubuntu A10 VM
.env.oci.example             # placeholders only
docs/hermes.md               # agent wiring
LICENSE                      # MIT
```

## License

MIT — see [LICENSE](LICENSE).

## Disclaimer

Unofficial. Not affiliated with Oracle. Cloud pricing, Free Tier rules, and GPU capacity change; verify in your Console. You are responsible for your tenancy and for not upgrading if you want zero card charges.
