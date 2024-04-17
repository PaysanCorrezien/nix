{ lib, config, pkgs, ... }:

let
  cfg = config.main-user;
in
{
  options.main-user = {
    enable = lib.mkEnableOption "enable user module";

    userName = lib.mkOption {
      type = lib.types.str;
      default = "mainuser";
      description = "Username of the main user.";
    };
  };

  config = lib.mkIf cfg.enable {
    users.users.${cfg.userName} = {
      isNormalUser = lib.mkDefault true;
      initialPassword = lib.mkDefault "12345";
      description = lib.mkDefault "Main user";
     #  shell = lib.mkDefault pkgs.zsh;
    };

    security.sudo.wheelNeedsPassword = lib.mkDefault false;
    security.sudo.extraConfig = lib.mkDefault ''
      ${cfg.userName} ALL=(ALL:ALL) NOPASSWD: ALL
    '';
  };
}

