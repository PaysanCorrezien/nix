{ config, pkgs, lib, ... }:

let
  cfg = config.settings;
# TEST: prepare for futur rebuild
  username = builtins.getEnv "USER";
  espansoConfigPath = "/home/${username}/.config/espanso/match/search.yml";
  espansoSetupScript = pkgs.writeShellScript "setup-espanso" ''
    if [ -f "${espansoConfigPath}" ]; then
      echo "Espanso config found. Skipping setup."
      exit 0
    fi

    if ! ${pkgs.gh}/bin/gh auth status &>/dev/null; then
      echo "GitHub CLI not authenticated. Skipping setup."
      exit 0
    fi

    echo "Espanso config not found. Cloning from GitHub..."
    github_username=$(${pkgs.gh}/bin/gh api user -q .login)
    if [ -z "$github_username" ]; then
      echo "Failed to get GitHub username. Aborting."
      exit 1
    fi

    rm -rf /home/${username}/.config/espanso
    cd /home/${username}/.config
    ${pkgs.gh}/bin/gh repo clone "$github_username/espanso.git" espanso
  '';
in
{
  config = lib.mkIf (cfg.displayServer != null) {
    services = lib.mkMerge [
      (lib.mkIf (cfg.displayServer == "xorg") {
        espanso = {
          enable = true;
          package = pkgs.espanso;
          wayland = false;
        };
      })
      (lib.mkIf (cfg.displayServer == "wayland") {
        espanso = {
          enable = true;
          package = pkgs.espanso-wayland;
          wayland = true;
        };
      })
    ];

    boot.kernelModules = [ "uinput" ];

    environment.systemPackages = [ pkgs.gh ];

    system.activationScripts.setupEspanso = lib.stringAfter [ "users" ] ''
      ${espansoSetupScript}
    '';
  };
}
