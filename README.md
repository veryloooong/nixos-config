# NixOS config

This Git repository holds the NixOS configuration for one laptop.

## Setup (fresh NixOS install)

1. Restore your SSH key to `~/.ssh/id_ed25519`. The `ssh-to-age` command below derives the age key from it.
2. Clone this repository to `~/nix`.
3. Create the symlink from `/etc/nixos` to `~/nix`.
4. Rebuild the system.

Run these commands:

```sh
mkdir -p ~/.config/sops/age
read -s SSH_TO_AGE_PASSPHRASE; export SSH_TO_AGE_PASSPHRASE
nix shell nixpkgs#ssh-to-age -c ssh-to-age \
  -private-key -i ~/.ssh/id_ed25519 \
  -o ~/.config/sops/age/keys.txt

git clone https://github.com/veryloooong/nixos-config ~/nix
sudo ln -s ~/nix /etc/nixos
sudo nixos-rebuild switch
```

## Secrets (sops-nix)

This repository uses [sops-nix](https://github.com/Mic92/sops-nix). It encrypts secrets, so you can commit them to Git safely.

### First-time setup

Add your API key to the encrypted file. sops encrypts the file when you save it.

```sh
cd ~/nix
nix shell nixpkgs#sops -c sops secrets/secrets.yaml
# In the editor:  deepseek-api-key: ***
# Save and exit. Then rebuild to deploy:
sudo nixos-rebuild switch
```

### View or edit secrets later

```sh
cd ~/nix && nix shell nixpkgs#sops -c sops secrets/secrets.yaml
```

### How it works

| Component         | What                                              | Managed by                                                             |
| ----------------- | ------------------------------------------------- | ---------------------------------------------------------------------- |
| Age key           | `~/.config/sops/age/keys.txt`                     | Derived from `~/.ssh/id_ed25519` via `ssh-to-age`                      |
| Encrypted file    | `secrets/secrets.yaml`                            | Committed to Git. Holds `deepseek-api-key`                             |
| System decryption | `configuration.nix` sops block                    | Extracts the key at build time. Writes `~/.config/claude-code/api-key` |
| Shell env         | `modules/zsh.nix` initContent                     | Reads the file and exports `ANTHROPIC_AUTH_TOKEN`                      |
| System env vars   | `configuration.nix` environment.variables         | `ANTHROPIC_BASE_URL`, model names, etc.                                |
