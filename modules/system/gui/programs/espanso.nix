{ config, pkgs, lib, ... }:

#FIXME: espanso on wayland is broken 
# https://github.com/NixOS/nixpkgs/issues/249364 
let cfg = config.settings;
in {
  config = lib.mkIf (cfg.displayServer != null) {
    services = lib.mkMerge [
      (lib.mkIf (cfg.displayServer == "xorg") {
        espanso = {
          enable = true;
          package = pkgs.espanso;
          wayland = false; # Ensure wayland is not enabled
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
  };
}

