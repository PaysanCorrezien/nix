{ config, lib, pkgs, ... }:

{
  options.settings = {
    # Core identification
    username = lib.mkOption {
      type = lib.types.str;
      default = "dylan";
      description = "Primary username for the system";
    };

    hostname = lib.mkOption {
      type = lib.types.str;
      default = "nixos";
      description = "System hostname";
    };

    locale = lib.mkOption {
      type = lib.types.str;
      default = "fr_FR.UTF-8";
      description = "System locale and language settings";
    };

    architecture = lib.mkOption {
      type = lib.types.enum [ "x86_64" "aarch64" "riscv64" ];
      default = "x86_64";
      description = "System CPU architecture";
    };

    environment = lib.mkOption {
      type = lib.types.enum [ "home" "work" ];
      default = "home";
      description = "Environment context affecting default application selection";
    };

    # Machine type flags
    isServer = lib.mkEnableOption "headless server mode (disables GUI, reduces packages)";

    isWSL = lib.mkEnableOption "Windows Subsystem for Linux mode";

    isExperimental = lib.mkEnableOption "experimental/unstable features";

    # Feature toggles
    work = lib.mkEnableOption "work-related applications" // { default = true; };

    gaming = lib.mkEnableOption "gaming-related applications" // { default = true; };

    autoSudo = lib.mkEnableOption "passwordless sudo for wheel group";

    # Display configuration
    windowManager = lib.mkOption {
      type = lib.types.nullOr (lib.types.enum [ "gnome" "plasma" "xfce" "hyprland" ]);
      default = "gnome";
      description = "Window manager selection (null for terminal-only)";
    };

    displayServer = lib.mkOption {
      type = lib.types.nullOr (lib.types.enum [ "xorg" "wayland" ]);
      default = "xorg";
      description = "Display server selection (null for terminal-only)";
    };

    # Submodules with enable flags
    virtualisation = {
      enable = lib.mkEnableOption "KVM/QEMU virtualisation support";
    };

    docker = {
      enable = lib.mkEnableOption "Docker container runtime";
    };

    social = {
      enable = lib.mkEnableOption "social applications (Discord, etc.)" // { default = true; };
    };

    yubikey = {
      enable = lib.mkEnableOption "YubiKey support for login and PAM";
    };

    # Paths configuration
    paths = {
      ageKeyFile = lib.mkOption {
        type = lib.types.str;
        default = "/var/lib/secrets/${config.settings.hostname}.txt";
        description = "Path to the Age key file for SOPS decryption";
      };

      homeDirectory = lib.mkOption {
        type = lib.types.str;
        default = "/home/${config.settings.username}";
        description = "Home directory path for the primary user";
      };

      flakeDirectory = lib.mkOption {
        type = lib.types.str;
        default = "${config.settings.paths.homeDirectory}/.config/nix";
        description = "Path to the NixOS flake configuration directory";
      };

      dotfilesUrl = lib.mkOption {
        type = lib.types.str;
        default = "https://github.com/PaysanCorrezien/dotfiles";
        description = "URL to the chezmoi dotfiles repository";
      };
    };
  };

  # Default configuration values
  config.settings = {
    username = lib.mkDefault "dylan";
    hostname = lib.mkDefault "nixos";
    locale = lib.mkDefault "fr_FR.UTF-8";
    architecture = lib.mkDefault "x86_64";
    environment = lib.mkDefault "home";
    isServer = lib.mkDefault false;
    isWSL = lib.mkDefault false;
    isExperimental = lib.mkDefault false;
    work = lib.mkDefault true;
    gaming = lib.mkDefault true;
    autoSudo = lib.mkDefault false;
    windowManager = lib.mkDefault "gnome";
    displayServer = lib.mkDefault "xorg";
    virtualisation.enable = lib.mkDefault false;
    docker.enable = lib.mkDefault false;
    social.enable = lib.mkDefault true;
    yubikey.enable = lib.mkDefault false;
  };
}
