{ settings, pkgs, lib, ... }:
let cfg = settings.terminal.extras;

in {
  config = lib.mkIf cfg.enable {

    home.packages = with pkgs; [ aichat ];

    xdg.configFile = {
      "aichat/config.yaml".text = ''
        ---
        model: openai
        clients:
          - type: openai
      '';
    };
  };
}

