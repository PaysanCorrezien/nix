{
  config,
  settings,
  lib,
  pkgs,
  ...
}:
let
  cfg = settings.terminal.extras;
in
{
  config = lib.mkIf cfg.enable {

    # Enable Carapace for better completions
    programs.carapace = {
      enable = true;
      enableNushellIntegration = true;
      enableZshIntegration = true;
    };
  };
}
