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

### WSL setup

```powershell
$dest="$env:USERPROFILE\NixOS";
if (!(Test-Path $dest)) {
    New-Item -ItemType Directory -Path $dest
};
$latestRelease = Invoke-RestMethod -Uri https://api.github.com/repos/nix-community/NixOS-WSL/releases/latest;
$asset = $latestRelease.assets | Where-Object { $_.name -eq 'nixos-wsl.tar.gz' };
Invoke-WebRequest -Uri $asset.browser_download_url -OutFile "$dest\nixos-wsl.tar.gz";
wsl --import NixOS $dest "$dest\nixos-wsl.tar.gz" --version 2;
wsl -d NixOS
```
