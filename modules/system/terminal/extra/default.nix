{ config, pkgs, lib, ... }:

let
  cfg = config.settings.terminal.extras;
  isServer =
    config.settings.isServer; # assuming this is where your isServer boolean is set
in {
  imports = [
    # ../home-manager/gnome/keybinds.nix
    ./dev.nix
  ];

  options.settings.terminal.extras = {
    enable = lib.mkEnableOption
      "Enable extra terminal configurations and packages, used for dev setup mostly";
  };

  config = {
    settings.terminal.extras.enable =
      !isServer; # Set to true if isServer is false

    environment.systemPackages = lib.mkIf cfg.enable (with pkgs; [
      ddcutil # attempt to control monitor
      # ddcui
      xorg.xinit
      gum
      navi
      # WORK
      powershell
      pandoc
      tokei
      gh
      ripgrep-all
      stylua
      gcc
      sshfs
    ]);
  };
}

