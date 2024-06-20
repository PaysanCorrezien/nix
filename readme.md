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

Update

```
nix flake update
```

FIXME: dont work like this i need to boot post install to have this work so the cp part is useless

```
nix-shell -p git --run "git clone https://github.com/PaysanCorrezien/nix /mnt/etc/nixos && mkdir -p /mnt/home/dylan/.config/nix && cp -r /mnt/etc/nixos/flake.nix /mnt/home/dylan/.config/nix/flake.nix && nixos-install --flake /mnt/home/dylan/.config/nix#default --impure && reboot"
```

## Bypass gnome idle timer

```bash
gsettings set org.gnome.settings-daemon.plugins.power sleep-inactive-ac-type 'nothing'
gsettings set org.gnome.settings-daemon.plugins.power sleep-inactive-battery-type 'nothing'
gsettings set org.gnome.settings-daemon.plugins.power power-off-inactive-ac-type 'nothing'
gsettings set org.gnome.settings-daemon.plugins.power power-off-inactive-battery-type 'nothing'
gsettings set org.gnome.desktop.session idle-delay 0
```

Once done

```bash
gsettings set org.gnome.desktop.session idle-delay 300
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

## Usefull ressources

[home manager option](https://nix-community.github.io/home-manager/options.xhtml)
