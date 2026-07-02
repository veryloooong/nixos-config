# My own NixOS config

One Git repo for NixOS configs for both my VMs and my laptop

- I have a NixOS VM at work. If I make more of them I will change the hardware config
- And I have a laptop

## Prerequisites for no bug setup

- Install MATLAB and setup according to this [GitLab repo](https://gitlab.com/doronbehar/nix-matlab)

## Setup (fresh NixOS install)

```sh
# 1. Clone to ~/nix
git clone https://github.com/veryloooong/nixos-config ~/nix

# 2. Restore your age key for sops decryption
#    Option A: copy from old machine
#      scp old-laptop:~/.config/sops/age/keys.txt ~/.config/sops/age/keys.txt
#
#    Option B: regenerate from your SSH key (if you used ssh-to-age)
#      nix shell nixpkgs#ssh-to-age -c ssh-to-age \
#        -private-key -i ~/.ssh/id_ed25519 -o ~/.config/sops/age/keys.txt
#
#    Option C: generate a new key, then re-encrypt secrets
#      nix shell nixpkgs#age -c age-keygen -o ~/.config/sops/age/keys.txt
#      cat ~/.config/sops/age/keys.txt | grep "public key" | cut -d' ' -f4
#      # → Add this public key to .sops.yaml, then on a machine with the old key:
#      cd ~/nix && sops updatekeys secrets/claude-code.yaml
#      git push && git pull  # on new laptop

# 3. Symlink to /etc/nixos
sudo ln -s ~/nix /etc/nixos

# 4. Create a host config for the new machine
#    Copy configuration-laptop.nix and hardware-configuration-laptop.nix,
#    generate hardware-config with: nixos-generate-config

# 5. Rebuild
sudo nixos-rebuild switch
```
