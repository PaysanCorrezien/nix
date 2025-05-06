{ config, lib, pkgs, ... }:

# Ultra‑minimal VMware host module.
# ‑ Always boots with DHCP via NetworkManager
# ‑ Partitions /dev/sda with the shared disko module

{
  ##############################################################################
  # Host‑specific toggles / options                                           #
  ##############################################################################
  options.settings.useDhcp = lib.mkOption {
    type        = lib.types.bool;
    default     = true;             # VMs default to DHCP
    description = "Enable DHCP/NetworkManager (static setup is off).";
  };

  ##############################################################################
  # Main host configuration                                                   #
  ##############################################################################
  config.settings = {
    # Identity
    hostname    = "vmware";
    username    = "dylan";

    # Hardware traits
    architecture          = "x86_64";
    virtualisation.enable = true;

    # Disk layout (shared logic lives in modules/options/disko.nix)
    disko.mainDisk = "/dev/sda";

    # Desktop
    windowManager = "gnome";
    displayServer = "wayland";
    ssh.enable = false;

    # Misc flags
    useDhcp      = true;
    isServer     = false;
    environment  = "home";
    gaming       = true;
    social.enable = true;
    locale       = "fr_FR.UTF-8";
    autoSudo     = true;
    tailscale.enable = false; # Disable Tailscale on this VM , require secret key

    # Disable YubiKey logic on this VM
    yubikey.enable = false;
  };

  ##############################################################################
  # Networking — DHCP only                                                    #
  ##############################################################################
  config.networking = {
    hostName = config.settings.hostname;

    networkmanager = {
      enable        = true;  # always on; no static‑IP fallback
      wifi.powersave = false;
    };
  };

  ##############################################################################
  # Packages                                                                  #
  ##############################################################################
  config.environment.systemPackages = with pkgs; [
    beets
  ];
}

