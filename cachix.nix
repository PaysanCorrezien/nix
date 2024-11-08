{
  config,
  lib,
  pkgs,
  ...
}:

{
  nix = {
    settings = {
      max-jobs = "auto";
      cores = 0;
      trusted-users = [
        "root"
        "dylan"
      ];
      # Include substituters and trusted-public-keys
      substituters = [
        "https://cache.nixos.org"
        "https://devenv.cachix.org"
      ];
      trusted-public-keys = [
        "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
        "devenv.cachix.org-1:w1cLUi8dv3hnoSPGAuibQv+f9TZLr6cv/Hm9XgU50cw="
      ];
    };

    extraOptions = ''
      experimental-features = nix-command flakes
      keep-outputs = true
      keep-derivations = true
      builders-use-substitutes = true
    '';
  };
}
