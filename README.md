# nixos-config

## Info

My personal config files for my daily environment, configured for Dell Inspiron 7590.

## Usage

```sh
git clone https://github.com/Ninlives/nixos-config.git
cd nixos-config

# Activate the system
sudo nix run .#world -- boot # switch/test

# Activate the home environment
nix run .#home
```
