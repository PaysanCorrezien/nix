{ config, pkgs, ... }:

{
  imports = [
    # ../home-manager/gnome/keybinds.nix
    ./btop.nix
    ./rust.nix
    ./fonts.nix
    #TODO:
  ];
}

