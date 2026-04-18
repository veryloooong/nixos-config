# My own NixOS config

One Git repo for NixOS configs for both my VMs and my laptop 

- I have a NixOS VM at work. If I make more of them I will change the hardware config
- And I have a laptop

## Prerequisites for no bug setup

- Install MATLAB and setup according to this [GitLab repo](https://gitlab.com/doronbehar/nix-matlab)

## Setup

```sh
# Clone to ~/nix
git clone https://github.com/veryloooong/nixos-config ~/nix

# Symlink to /etc/nixos
sudo ln -s ~/nix /etc/nixos

# Edit all of the files for yourself! Change the username and hostname as you'd like.
# Then just rebuild the system
sudo nixos-rebuild switch
```
