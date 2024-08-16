{ config, lib, pkgs, ... }:

let
  globalDefaults = {
    username = lib.mkDefault "dylan";
    hostname = lib.mkDefault "nixos"; # Default hostname
    isServer = lib.mkDefault false;
    locale = lib.mkDefault "fr_FR.UTF-8";
    virtualisation.enable = lib.mkDefault false;
    environment = lib.mkDefault "home";
    isExperimental = lib.mkDefault false; # NOTE: this is not currently used
    work = lib.mkDefault true; # NOTE: install work apps
    gaming = lib.mkDefault true;
    tailscale.enable = lib.mkDefault false; # Enable Tailscale by default
    windowManager = lib.mkDefault "gnome"; # Default window manager
    displayServer = lib.mkDefault "xorg"; # Default display server
    ai.enable = lib.mkDefault false; # Enable AI tools
    social.enable = lib.mkDefault true; # NOTE: install social apps like discord
    architecture = lib.mkDefault "x86_64"; # Default architecture
    tailscaleIP = lib.mkDefault "100.100.100.120"; # Default Tailscale IP
    minimalNvim = lib.mkDefault false; # Default to full Neovim configuration
  };
in {
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
      tailscale.enable = lib.mkOption {
        type = lib.types.bool;
        default = globalDefaults.tailscale.enable;
        description = "Enable Tailscale.";
      };
      windowManager = lib.mkOption {
        type = lib.types.nullOr
          (lib.types.enum [ "gnome" "plasma" "xfce" "hyprland" ]);
        default = globalDefaults.windowManager;
        description = "Choose window manager (gnome, plasma, xfce, hyprland).";
      };
      displayServer = lib.mkOption {
        type = lib.types.nullOr (lib.types.enum [ "xorg" "wayland" ]);
        default = globalDefaults.displayServer;
        description = "Choose display server (wayland, xorg).";
      };
      ai.enable = lib.mkOption {
        type = lib.types.bool;
        default = globalDefaults.ai.enable;
        description = "Enable AI tools.";
      };
      architecture = lib.mkOption {
        type = lib.types.enum [ "x86_64" "aarch64" "riscv64" ];
        default = globalDefaults.architecture;
        description = "Choose system architecture (x86_64, aarch64, riscv64).";
      };
      tailscaleIP = lib.mkOption {
        type = lib.types.str;
        default = globalDefaults.tailscaleIP;
        description = "Tailscale IP address for the system.";
      };
      minimalNvim = lib.mkOption {
        type = lib.types.bool;
        default = globalDefaults.minimalNvim;
        description = "Use minimal Neovim configuration.";
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
      tailscale.enable = globalDefaults.tailscale.enable;
      windowManager = globalDefaults.windowManager;
      displayServer = globalDefaults.displayServer;
      ai.enable = globalDefaults.ai.enable;
      architecture = globalDefaults.architecture;
      tailscaleIP = globalDefaults.tailscaleIP;
      minimalNvim = globalDefaults.minimalNvim;
    };

  };
}
