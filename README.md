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
