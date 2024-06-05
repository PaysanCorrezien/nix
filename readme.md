
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

