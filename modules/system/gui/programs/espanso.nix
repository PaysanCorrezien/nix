{
  config,
  pkgs,
  lib,
  ...
}:
let
  cfg = config.settings;
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
  imports = [
    # CREDIT: https://github.com/NixOS/nixpkgs/issues/249364#issuecomment-2336599201
    ./espanso-capdacoverride/default.nix
  ];
  # services.espanso.enable = false
  config = lib.mkIf (cfg.displayServer != null) {
    # Enable the capdacoverride capability for Wayland
    programs.espanso.capdacoverride.enable = true;

    services.espanso = {
      enable = true;
      package = config.programs.espanso.capdacoverride.package;
    };

    boot.kernelModules = [ "uinput" ];
    environment.systemPackages = [ pkgs.gh ];
    system.activationScripts.setupEspanso = lib.stringAfter [ "users" ] ''
      ${espansoSetupScript}
    '';
  };
}
