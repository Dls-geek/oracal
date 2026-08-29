# Contributing to oci-watchdog

Thanks for helping guard Free Trial credits for more people.

## Rules

- **Never** add Upgrade / Pay As You Go / payment-method automation.
- **Never** commit secrets: `.env.oci`, `*.pem`, OCI private keys, SSH private keys.
- Prefer read-only billing/usage APIs for `credits` / `status`.
- Keep the CLI portable Bash; avoid requiring root on the laptop (VM bootstrap may use `sudo` on the instance).
- Document Free Trial limits honestly (e.g. `gpu-a10-count` is often `0`).

## Development

```bash
cp .env.oci.example .env.oci   # local only
./bin/watchdog help
bash -n bin/watchdog scripts/setup-ollama.sh
```

## Pull requests

1. Fork and branch from `main`
2. Small, focused changes
3. Update README/docs if behavior changes
4. Do not force-push other people's history

## License

By contributing, you agree your contributions are licensed under the MIT License (see [LICENSE](LICENSE)).
