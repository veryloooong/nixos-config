# My own NixOS config

One Git repo for NixOS configs for both my VMs and my laptop but I will install NixOS on laptop later when I'm used to it

## Todos

- [x] `home-manager` and user settings
- [ ] Setup productivity suite
- [ ] OneDrive
- [ ] Unite configurations (same on laptop and VM, just with a different hardware config)
- [ ] Makefile or something convenient (or no need)

## Setup

```sh
# Clone to ~/nix
git clone https://github.com/veryloooong/nixos-config ~/nix

# Symlink to /etc/nixos
sudo ln -s ~/nix/nixos /etc/nixos

# Edit all of the files for yourself! Change the username and hostname as you'd like.
# Then just rebuild the system
sudo nixos-rebuilt switch
```
