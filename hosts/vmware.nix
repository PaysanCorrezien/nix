{ config, lib, pkgs, ... }:

# Minimal, VM‑friendly host module.
# ‑ DHCP is always on (via NetworkManager)
# ‑ The virtual disk is /dev/sda (24 GiB in your lsblk)

let
  wifiKey = lib.optionalString (builtins.pathExists "/run/secrets/wifi_homekey") (
    builtins.readFile "/run/secrets/wifi_homekey"
  );
in {
  ## ─────── Host‑specific options ───────────────────────────────────────────────
  options.settings.useDhcp = lib.mkOption {
    type        = lib.types.bool;
    default     = true;         # VMs always boot with DHCP
    description = "Enable DHCP/NetworkManager (static setup is off by default).";
  };

  ## ─────── Host‑specific configuration ────────────────────────────────────────
  config.settings = {
    # Identity
    hostname   = "vmware";
    username   = "dylan";

    # Hardware / target tweaks
    architecture = "x86_64";
    virtualisation.enable = true;

    # Disk layout
    disko.mainDisk = "/dev/sda";

    # Desktop
    windowManager  = "gnome";
    displayServer  = "xorg";

    # Misc toggles
    useDhcp       = true;   # <- derives networking behaviour below
    isServer      = false;
    environment   = "home";
    tailscale.enable = true;
    gaming        = true;
    social.enable = true;
    locale        = "fr_FR.UTF-8";
    autoSudo      = true;

    yubikey = {
      enable = false;
    };
  };

  ## ─────── Networking (DHCP vs static) ────────────────────────────────────────
  config.networking = {
    hostName = config.settings.hostname;

    # Always run NetworkManager when useDhcp == true
    networkmanager = {
      enable        = config.settings.useDhcp;
      wifi.powersave = false;
    };

    # Static‑IP fallback (unused when useDhcp == true)
    wireless = lib.mkIf (!config.settings.useDhcp) {
      enable               = true;
      networks."Dylan-Box".psk = wifiKey;
      userControlled.enable = true;
    };

    interfaces.wlp4s0 = lib.mkIf (!config.settings.useDhcp) {
      useDHCP = false;
      ipv4.addresses = [{ address = "192.168.1.111"; }];
    };

    defaultGateway = lib.mkIf (!config.settings.useDhcp) {
      address   = "192.168.1.1";
      interface = "wl01";
    };

    nameservers = lib.mkIf (!config.settings.useDhcp) [ "1.1.1.1" "8.8.8.8" ];
  };

  ## ─────── Packages ───────────────────────────────────────────────────────────
  config.environment.systemPackages = with pkgs; [
    beets
    # add more here if you like
  ];
}

