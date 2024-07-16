{ config, pkgs, ... }:

{
  imports = [
    # ../home-manager/gnome/keybinds.nix
    ./core/default.nix
    #TODO:
    # make this cnditina imports base on variable
    ./extras/default.nix
  ];
}

