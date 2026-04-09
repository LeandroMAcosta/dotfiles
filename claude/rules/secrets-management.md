## Secrets Management (1Password CLI)

- Never ask the user for secrets, tokens, or credentials. Fetch them from 1Password using `op`.
- Secrets are stored in the **Developer Secrets** vault.
- Always use `--reveal` when reading field values, otherwise `op` returns a masked reference.

### Fetching a secret

```bash
op item get "<Item Name>" --vault "Developer Secrets" --fields label=<field> --reveal
```

Common field labels vary per item: `credential`, `password`, `secret-key`, `access-key-id`. List fields first if unsure:

```bash
op item get "<Item Name>" --vault "Developer Secrets" --format json | python3 -c "import json,sys; [print(f['label']) for f in json.load(sys.stdin).get('fields',[])]"
```

### Inline usage (single command)

Export the secret into an env var for a single command without persisting it:

```bash
export MY_SECRET="$(op item get '<Item Name>' --vault 'Developer Secrets' --fields label=<field> --reveal)" && <command using $MY_SECRET>
```

### Available items in Developer Secrets vault

Cloudflare, Grafana, MercadoPago, Azure DevOps, Anthropic, AWS Access Key (esqueldev), id_ed25519_leacosta97.
