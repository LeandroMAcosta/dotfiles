#!/usr/bin/env bash
set -euo pipefail

# GitHub (github.com) + Bitbucket (bitbucket.org) SSH keys. Stored in 1Password
# but written to disk so commits/pushes use the local key directly (see the
# IdentityAgent none entries in ~/.ssh/config) and never trigger a per-use
# 1Password SSH agent approval prompt.
command -v op &>/dev/null || exit 0
op account list &>/dev/null || exit 0

for key_item in id_ed25519_leacosta97 id_ed25519_engbim; do
  key_path="$HOME/.ssh/$key_item"
  [[ -f "$key_path" ]] && continue
  op read "op://Developer Secrets/$key_item/private key?ssh-format=openssh" > "$key_path" 2>/dev/null \
    && chmod 600 "$key_path" \
    && op item get "$key_item" --vault "Developer Secrets" \
         --fields label="public key" --reveal 2>/dev/null | tr -d '"' > "$key_path.pub" \
    && chmod 644 "$key_path.pub" \
    && echo "  Wrote SSH key $key_item from 1Password"
done
