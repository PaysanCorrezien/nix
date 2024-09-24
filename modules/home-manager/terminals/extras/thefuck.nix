{ config,settings, lib, pkgs, ... }:
let cfg = settings.terminal.extras;
in {
  config = lib.mkIf cfg.enable {
  programs.thefuck.enable = true;
  programs.thefuck.enableNushellIntegration = true;
  programs.thefuck.enableZshIntegration = true;
  };
}

