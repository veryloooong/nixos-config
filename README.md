# My own NixOS config

One Git repo for NixOS configs for both my VMs and my laptop

- I have a NixOS VM at work. If I make more of them I will change the hardware config
- And I have a laptop

## Prerequisites for no bug setup

- Install MATLAB and setup according to this [GitLab repo](https://gitlab.com/doronbehar/nix-matlab)

## Setup (fresh NixOS install)

```sh
# 1. Restore your SSH key (~/.ssh/id_ed25519) — the age key is derived from it
mkdir -p ~/.config/sops/age
read -s SSH_TO_AGE_PASSPHRASE; export SSH_TO_AGE_PASSPHRASE
nix shell nixpkgs#ssh-to-age -c ssh-to-age \
  -private-key -i ~/.ssh/id_ed25519 \
  -o ~/.config/sops/age/keys.txt

# 2. Clone to ~/nix
git clone https://github.com/veryloooong/nixos-config ~/nix

# 3. Symlink to /etc/nixos
sudo ln -s ~/nix /etc/nixos

# 4. Create a host config for the new machine
#    Copy configuration-laptop.nix and hardware-configuration-laptop.nix,
#    generate hardware-config with: nixos-generate-config

# 5. Rebuild
sudo nixos-rebuild switch
```

## Secrets (sops-nix)

This repo uses [sops-nix](https://github.com/Mic92/sops-nix) to encrypt secrets so they can be safely committed to Git.

### First-time setup

```sh
# Paste your DeepSeek API key into the encrypted file:
cd ~/nix
nix shell nixpkgs#sops -c sops secrets/claude-code.yaml
# In the editor:  deepseek-api-key: sk-your-key-here
# Save & exit — sops encrypts it automatically.

# Rebuild to deploy:
sudo nixos-rebuild switch
```

### View/edit secrets later

```sh
cd ~/nix && nix shell nixpkgs#sops -c sops secrets/claude-code.yaml
```

### How it works

| Component         | What                                             | Managed by                                                            |
| ----------------- | ------------------------------------------------ | --------------------------------------------------------------------- |
| Age key           | `~/.config/sops/age/keys.txt`                    | Derived from `~/.ssh/id_ed25519` via `ssh-to-age`                     |
| Encrypted file    | `secrets/claude-code.yaml`                       | Committed to Git, holds `deepseek-api-key`                            |
| System decryption | `configuration-common.nix` sops block            | Extracts key at build time, writes to `~/.config/claude-code/api-key` |
| Shell env         | `modules/zsh.nix` initContent                    | Reads the file and exports `ANTHROPIC_AUTH_TOKEN`                     |
| System env vars   | `configuration-common.nix` environment.variables | `ANTHROPIC_BASE_URL`, model names, etc.                               |

### Claude Code → DeepSeek

Claude Code talks directly to [DeepSeek's Anthropic-compatible API](https://api-docs.deepseek.com/quick_start/agent_integrations/claude_code) at `https://api.deepseek.com/anthropic`. No translation layer needed.

Model mapping:
| Claude model | Maps to DeepSeek |
|---|---|
| Opus | `deepseek-v4-pro` |
| Sonnet | `deepseek-v4-pro` |
| Haiku | `deepseek-v4-flash` |
