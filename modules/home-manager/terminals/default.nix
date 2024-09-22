{ config, pkgs, ... }:

{
  imports = [
    # ../home-manager/gnome/keybinds.nix
    ./core/default.nix
    ./extras/default.nix
    ./nushell.nix
  ];
}

