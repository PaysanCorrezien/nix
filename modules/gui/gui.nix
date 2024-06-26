{ config, pkgs, ... }:


{
  imports = [
  ./virtualisation.nix
  ./dev/python.nix
  # ./programs/thunderbird.nix
  # ../home-manager/gnome/keybinds.nix
  ];


}

