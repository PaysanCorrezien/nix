{ config, settings, lib, pkgs, ... }:
let cfg = settings.terminal.extras;
in {
  config = lib.mkIf cfg.enable {
    # thefuck was removed from nixpkgs, using pay-respects as replacement
    programs.pay-respects.enable = true;
    programs.pay-respects.enableZshIntegration = true;
  };
}
