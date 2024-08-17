{ config, lib, pkgs, ... }:
let
  # NOTE:
  # this allow change this config on the fly : 
  # sudo USE_DHCP=1 nixos-rebuild switch --flake "/home/dylan/.config/nix#lenovo" --impure --show-trace
  # i want this to be able if needed to enable networkmanager quickly
  # and i cant get wifi no work with fix ip on networkmanage + networkmanager cant coexixst with a static ip defined 'outside'.... 💀
  # TODO: find abetter way to passs argument to nixos-rebuild switch to not use this poor method
  # TODO: create a command or alias for this
  useDhcp = if builtins.getEnv "USE_DHCP" == "1" then
    true
  else if builtins.hasAttr "useDhcp" config.settings then
    config.settings.useDhcp
  else
    false;

  wifiKey = lib.optionalString (builtins.pathExists "/run/secrets/wifi_homekey")
    (builtins.readFile "/run/secrets/wifi_homekey");
in {
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
    tailscale.enable = true;
    windowManager = "gnome";
    displayServer = "xorg";
    ai.enable = false;
    social.enable = true;
    architecture = "x86_64";
    tailscaleIP = "100.100.100.110";
    minimalNvim = false;
    hostname = "lenovo";
  };

  config.networking = {
    hostName = config.settings.hostname;

    # Wireless configuration (only used when not using NetworkManager)
    wireless = lib.mkIf (!useDhcp) {
      enable = true;
      networks = { "Dylan-Box" = { psk = wifiKey; }; };
      userControlled.enable = true;
    };

    # NetworkManager configuration (only used when useDhcp is true)
    networkmanager = {
      enable = useDhcp;
      wifi.powersave = false;
    };

    # Static IP configuration (used when useDhcp is false)
    interfaces.wlp4s0 = lib.mkIf (!useDhcp) {
      useDHCP = false;
      ipv4.addresses = [{
        address = "192.168.1.110";
        prefixLength = 24;
      }];
    };

    defaultGateway = lib.mkIf (!useDhcp) {
      address = "192.168.1.1";
      interface = "wlp4s0";
    };

    nameservers = lib.mkIf (!useDhcp) [ "1.1.1.1" "8.8.8.8" ];
  };

}

