{ config, pkgs, ... }:

{
  imports = [
    # ../home-manager/gnome/keybinds.nix
  ];
  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = true;
  };
}

