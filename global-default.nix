{ config, lib, pkgs, ... }:

#TODO:: move all this out of here , and inside their related file
# find a way to genreate the doc for the options
let
  globalDefaults = {
    username = lib.mkDefault "dylan";
    hostname = lib.mkDefault "nixos";
    isServer = lib.mkDefault false;
    locale = lib.mkDefault "fr_FR.UTF-8";
    virtualisation.enable = lib.mkDefault false;
    environment = lib.mkDefault "home";
    isExperimental = lib.mkDefault false;
    work = lib.mkDefault true;
    gaming = lib.mkDefault true;
    windowManager = lib.mkDefault "gnome";
    displayServer = lib.mkDefault "xorg";
    docker.enable = lib.mkDefault false;
    social.enable = lib.mkDefault true;
    architecture = lib.mkDefault "x86_64";
    autoSudo = lib.mkDefault false;
  };
in
{
  options = {
    settings = {
      username = lib.mkOption {
        type = lib.types.str;
        default = globalDefaults.username;
        description = "Username for the system.";
      };
      hostname = lib.mkOption {
        type = lib.types.str;
        default = globalDefaults.hostname;
        description = "Hostname for the system.";
      };
      isServer = lib.mkOption {
        type = lib.types.bool;
        default = globalDefaults.isServer;
        description = "Is it a server?";
      };
      locale = lib.mkOption {
        type = lib.types.str;
        default = globalDefaults.locale;
        description = "Locale lang settings for the system.";
      };
      virtualisation.enable = lib.mkOption {
        type = lib.types.bool;
        default = globalDefaults.virtualisation.enable;
        description = "Do I run VM on this host?";
      };
      environment = lib.mkOption {
        type = lib.types.enum [ "home" "work" ];
        default = globalDefaults.environment;
        description = "The environment setting (home or work).";
      };
      isExperimental = lib.mkOption {
        type = lib.types.bool;
        default = globalDefaults.isExperimental;
        description = "Is this an experimental machine?";
      };
      social.enable = lib.mkOption {
        type = lib.types.bool;
        default = globalDefaults.social.enable;
        description = "Install social apps like Discord.";
      };
      work = lib.mkOption {
        type = lib.types.bool;
        default = globalDefaults.work;
        description = "Install work-related applications.";
      };
      gaming = lib.mkOption {
        type = lib.types.bool;
        default = globalDefaults.gaming;
        description = "Install gaming-related applications.";
      };
      windowManager = lib.mkOption {
        type = lib.types.nullOr
          (lib.types.enum [ "gnome" "plasma" "xfce" "hyprland" ]);
        default = globalDefaults.windowManager;
        description =
          "Choose window manager (gnome, plasma, xfce, hyprland) or null for terminal-only.";
      };
      displayServer = lib.mkOption {
        type = lib.types.nullOr (lib.types.enum [ "xorg" "wayland" ]);
        default = globalDefaults.displayServer;
        description =
          "Choose display server (wayland, xorg) or null for terminal-only.";
      };
        docker = {
          enable = lib.mkOption {
            type = lib.types.bool;
            default = globalDefaults.docker.enable;
            description = "Enable docker and its settings on host.";
          };
      };
      architecture = lib.mkOption {
        type = lib.types.enum [ "x86_64" "aarch64" "riscv64" ];
        default = globalDefaults.architecture;
        description = "Choose system architecture (x86_64, aarch64, riscv64).";
      };
      autoSudo = lib.mkOption {
        type = lib.types.bool;
        default = globalDefaults.autoSudo;
        description =
          "Add users to sudoers with no password and allow access to home manager service for user.";
      };
    };
  };

  config = {
    settings = {
      username = globalDefaults.username;
      isServer = globalDefaults.isServer;
      hostname = globalDefaults.hostname;
      locale = globalDefaults.locale;
      virtualisation.enable = globalDefaults.virtualisation.enable;
      environment = globalDefaults.environment;
      isExperimental = globalDefaults.isExperimental;
      social.enable = globalDefaults.social.enable;
      work = globalDefaults.work;
      gaming = globalDefaults.gaming;
      windowManager = globalDefaults.windowManager;
      displayServer = globalDefaults.displayServer;
      docker.enable = globalDefaults.docker.enable;
      architecture = globalDefaults.architecture;
      autoSudo = globalDefaults.autoSudo;
    };
  };
}
