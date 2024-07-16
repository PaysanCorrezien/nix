{ config, pkgs, lib, ... }:

let cfg = config.settings.terminal.extras;
in {
  imports = [
    # ../home-manager/gnome/keybinds.nix
    ./dev.nix
  ];

  options.settings.terminal.extras = {
    enable = lib.mkEnableOption
      "Enable extra terminal configurations and packages, used for dev setup mostly";
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      btop
      ddcutil # attempt to control monitor
      # ddcui
      xorg.xinit
      shell-gpt
      gum
      # WORK
      powershell
      pandoc
      tokei
      gh
      ripgrep-all
      gitui
      stylua
      gcc
    ];
  };
}
