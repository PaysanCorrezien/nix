{
  config,
  lib,
  pkgs,
  ...
}:

# Ultra‑minimal VMware host module.
# ‑ Always boots with DHCP via NetworkManager
# ‑ Partitions /dev/sda with the shared disko module

{
  ##############################################################################
  # Host‑specific toggles / options                                           #
  ##############################################################################
  options.settings.useDhcp = lib.mkOption {
    type = lib.types.bool;
    default = true; # VMs default to DHCP
    description = "Enable DHCP/NetworkManager (static setup is off).";
  };

  ##############################################################################
  # Main host configuration                                                   #
  ##############################################################################
  config.settings = {
    # TYPE
    isServer = false;
    # Identity
    hostname = "vmware";
    username = "dylan";

    # Hardware traits
    architecture = "x86_64";
    virtualisation.enable = true;

    # Disk layout (shared logic lives in modules/options/disko.nix)
    disko.mainDisk = "/dev/sda";
    disko.layout = "standard"; # Standard layout with ESP

    # Desktop
    windowManager = "niri";
    displayServer = "wayland";
    ssh.enable = false;

    # Misc flags
    useDhcp = true;
    environment = "home";
    gaming = false;
    social.enable = false;
    locale = "fr_FR.UTF-8";
    autoSudo = true;
    tailscale.enable = false; # Disable Tailscale on this VM , require secret key

    # Disable YubiKey logic on this VM
    yubikey.enable = false;
  };
  config.users.users.${config.settings.username} = {
    # initialPassword = "dylan"; #TODO: put pass in sops as users.users.your-user.initialHashedPassword
    initialHashedPassword = "$6$.NL5Jii4wwztUzFC$pOiZJ3I2810HLcCZc0CYR5YGEHS6JWibJ75mbx4TWcm0gsxuEAsSK4rsDxu1Ny7o67..V4hdX3mwJQ4enHCJ6."; # dylan for test

    group = "dylan";
    home = "/home/${config.settings.username}";
  };
  config.users.groups.dylan = { };

  config.virtualisation.vmware.guest.enable = true; # pulls in the open-vm-tools set,

  ##############################################################################
  # Networking — DHCP only                                                    #
  ##############################################################################
  config.networking = {
    hostName = config.settings.hostname;

    networkmanager = {
      enable = true; # always on; no static‑IP fallback
      wifi.powersave = false;
    };
  };

  ##############################################################################
  # Packages                                                                  #
  ##############################################################################
}
