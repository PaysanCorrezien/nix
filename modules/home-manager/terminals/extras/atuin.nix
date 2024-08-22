{ pkgs, lib, settings, ... }:

#NOTE: these should only be enable on desktop like system which should access atuin synx serv
let 
  cfg = settings.terminal.extras;
  readSecretFile = file:
    lib.optionalString (builtins.pathExists file) (builtins.readFile file);
  secrets = readSecretFile "/run/secrets/atuin_sync_address";

in {
  config = lib.mkIf cfg.enable {
    programs.atuin = {
      enable = true;
#NOTE: atuin ssettings are creating the atuin.toml file which is located in ~/.config/atuin/config.toml
      settings = {
        auto_sync = true;
        sync_frequency = "5m";
        sync_address = "${secrets}";
        search_mode = "prefix";
        enter_accept = false; #NOTE: enter doesnt rerun but paste to zsh
      };
    };
    programs.zsh.initExtra = ''
      eval "$(atuin init zsh)"
    '';
  };
}
