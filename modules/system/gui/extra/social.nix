{
  config,
  pkgs,
  lib,
  ...
}:

let
  cfg = config.settings.social;
in
{
  config = lib.mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      element-desktop
      # vesktop # If you prefer this
      vencord

      (discord.override {
        # withOpenASAR = true; # can do this here too
        withVencord = true;
      })
    ];
  };
}
