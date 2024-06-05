```
sudo nixos-rebuild switch --flake '/etc/nixos#default'  --verbose --show-trace
```

```
chezmoi init --apply https://github.com/PaysanCorrezien/dotfiles
```

Finding a package :

```
nix-store -q --tree $(which fzf)
```

```
sudo nixos-rebuild switch --flake ~/.config/nix#default --impure --show-trace -v
```

TODO : test the automatic setup:

```
nix-shell -p git --run "git clone https://github.com/PaysanCorrezien/nix /mnt/etc/nixos && mkdir -p /mnt/home/dylan/.config/nix && cp -r /mnt/etc/nixos/flake.nix /mnt/home/dylan/.config/nix/flake.nix && nixos-install --flake /mnt/home/dylan/.config/nix#default && reboot"
```
