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

FIXME: dont work like this i need to boot post install to have this work so the cp part is useless

```
nix-shell -p git --run "git clone https://github.com/PaysanCorrezien/nix /mnt/etc/nixos && mkdir -p /mnt/home/dylan/.config/nix && cp -r /mnt/etc/nixos/flake.nix /mnt/home/dylan/.config/nix/flake.nix && nixos-install --flake /mnt/home/dylan/.config/nix#default --impure && reboot"
```

## Bypass gnome idle timer

```bash
gsettings set org.gnome.desktop.session idle-delay 43200
```

Once done

```bash
gsettings set org.gnome.desktop.session idle-delay 300
```
