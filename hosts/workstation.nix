{
  config,
  lib,
  pkgs,
  ...
}:
let
  # NOTE:
  # this allow change this config on the fly :
  # sudo USE_DHCP=1 nixos-rebuild switch --flake "/home/dylan/.config/nix#lenovo" --impure --show-trace
  # i want this to be able if needed to enable networkmanager quickly
  # and i cant get wifi no work with fix ip on networkmanage + networkmanager cant coexixst with a static ip defined 'outside'.... 💀
  # TODO: find abetter way to passs argument to nixos-rebuild switch to not use this poor method
  useDhcp =
    if builtins.getEnv "USE_DHCP" == "1" then
      true
    else if builtins.hasAttr "useDhcp" config.settings then
      config.settings.useDhcp
    else
      false;

  wifiKey = lib.optionalString (builtins.pathExists "/run/secrets/wifi_homekey") (
    builtins.readFile "/run/secrets/wifi_homekey"
  );
in
{
  options.settings.useDhcp = lib.mkOption {
    type = lib.types.bool;
    default = false;
    description = "Whether to use DHCP instead of static IP";
  };

  config.settings = {
    username = "dylan";
    isServer = false;
    locale = "fr_FR.UTF-8";
    virtualisation.enable = true;
    environment = "home";
    isExperimental = false;
    work = true;
    gaming = true;
    windowManager = "gnome";
    # windowManager = "hyprland";
    # windowManager  = "plasma";
    # displayServer = "xorg";
    displayServer = "wayland";
    social.enable = true;
    architecture = "x86_64";
    autoSudo = true;
    hostname = "workstation";
    useDhcp = false;
    # useDhcp = true;
    disko = {
      mainDisk = "/dev/nvme0n1"; # Set this for your laptop with NVMe
      layout = "standard"; # Add this line
    };
    sops = {
      #NOTE: from sops.nix file
      enable = true;
      enableGlobal = true;
      machineType = "desktop"; # or "homeserver" or "vps"
    };
    monitoring = {
      enable = true;
    };
    tailscale.enable = true;
    tailscale.tags = [ "computer" ];
    # rdpserver = {
    #   enable = true;
    # };
  };

  config = {
    networking = {
      hostName = config.settings.hostname;
      wireless = lib.mkIf (!useDhcp) {
        enable = true;
        networks = {
          "Dylan-Box" = {
            psk = wifiKey;
          };
        };
        userControlled.enable = true;
      };
      networkmanager = {
        enable = useDhcp;
        wifi.powersave = false;
      };
      useDHCP = useDhcp;

      interfaces.wlp4s0 = lib.mkIf (!useDhcp) {
        ipv4.addresses = [
          {
            address = "192.168.1.110";
            prefixLength = 24;
          }
        ];
      };
      defaultGateway = lib.mkIf (!useDhcp) {
        address = "192.168.1.1";
        interface = "wlp4s0";
      };
      nameservers = lib.mkIf (!useDhcp) [
        "1.1.1.1"
        "8.8.8.8"
      ];
    };

    users.groups.plugdev = { }; # Create the plugdev group

  };

}
