{ config, lib, pkgs, ... }:

let
  globalDefaults = {
    username = lib.mkDefault "dylan";
    ip = lib.mkDefault "192.168.0.111"; # NOTE: this is not currently used
    isServer = lib.mkDefault false;
    virtualisation.enable = lib.mkDefault false;
    environment = lib.mkDefault "home";
    isExperimental = lib.mkDefault false; # NOTE: this is not currently used
    social.enable = lib.mkDefault true; # NOTE: install social apps like discord
    work = lib.mkDefault true; # NOTE: install work apps
    gaming = lib.mkDefault true;
    tailscale.enable = lib.mkDefault false; # Enable Tailscale by default
    windowManager = lib.mkDefault "gnome"; # Default window manager
    displayServer = lib.mkDefault "xorg"; # Default display server
  };
in {
  options = {
    settings = {
      username = lib.mkOption {
        type = lib.types.str;
        default = globalDefaults.username;
        description = "Username for the system.";
      };
      ip = lib.mkOption {
        type = lib.types.str;
        default = globalDefaults.ip;
        description = "IP address for the system.";
      };
      isServer = lib.mkOption {
        type = lib.types.bool;
        default = globalDefaults.isServer;
        description = "Is it a server?";
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
      tailscale.enable = lib.mkOption {
        type = lib.types.bool;
        default = globalDefaults.tailscale.enable;
        description = "Enable Tailscale.";
      };
      windowManager = lib.mkOption {
        type = lib.types.nullOr
          (lib.types.enum [ "gnome" "plasma" "xfce" "hyprland" ]);
        default = globalDefaults.windowManager;
        description = "Choose window manager (gnome, plasma, xfce).";
      };
      displayServer = lib.mkOption {
        type = lib.types.nullOr (lib.types.enum [ "xorg" "wayland" ]);
        default = globalDefaults.displayServer;
        description = "Choose display server (wayland, xorg).";
      };
    };
  };

  config.settings = {
    username = globalDefaults.username;
    ip = globalDefaults.ip;
    isServer = globalDefaults.isServer;
    virtualisation.enable = globalDefaults.virtualisation.enable;
    environment = globalDefaults.environment;
    isExperimental = globalDefaults.isExperimental;
    social.enable = globalDefaults.social.enable;
    work = globalDefaults.work;
    gaming = globalDefaults.gaming;
    tailscale.enable = globalDefaults.tailscale.enable;
    windowManager = globalDefaults.windowManager;
    displayServer = globalDefaults.displayServer;
  };
}

