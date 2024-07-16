{ config, pkgs, lib, ... }:

let cfg = config.settings.terminal.extras;
in {
  # config = lib.mkIf cfg.enable {
  home.packages = with pkgs; [
    (nerdfonts.override { fonts = [ "FiraCode" "DroidSansMono" ]; })
    monaspace
  ];
  # };
}
