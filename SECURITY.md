# Security Policy

## Supported versions

This project targets the latest `main` branch only.

## Reporting a vulnerability

If you find a security issue (e.g. accidental secret exposure, unsafe defaults that open Ollama to the internet):

1. **Do not** open a public GitHub issue with secrets or exploit details.
2. Contact the maintainer via GitHub Security Advisories on this repository (preferred), or privately through the account that owns the repo.

## Hardening expectations

- Ollama must bind to **127.0.0.1** only; access via SSH tunnel.
- Security lists should allow **SSH from your IP**, not `0.0.0.0/0` for model ports.
- API signing keys and `.env.oci` stay on the operator's machine — never in git.

## Out of scope

- Oracle Cloud Infrastructure platform bugs (report to Oracle).
- Abuse of Free Trial policy (not supported; one trial per person).
