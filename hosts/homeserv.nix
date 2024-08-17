# homeserver.nix
{ config, pkgs, ... }:

{
  config.settings = {
    username = "dylan";
    isServer = true;
    locale = "fr_FR.UTF-8";
    # virtualisation.enable = true;
    environment = "home";
    isExperimental = false;
    work = false;
    gaming = false;
    tailscale.enable = true;
    windowManager = "gnome";
    displayServer = "xorg";
    ai.enable = true;
    social.enable = false;
    architecture = "x86_64";
    tailscaleIP = "100.100.110.20";
    minimalNvim = false;
    hostname = "homeserver";
    ai.server.enable = true;
  };

  # Enable SSH
  services.openssh.enable = true;

  # TODO: make this automatic too , with card detection and only to the primary one ?
  # Configure static IP dynamically
  networking = {
    hostName = "homeserver"; # Define the hostname
    defaultGateway.interface = "enp7s0";
    defaultGateway.address = "192.168.1.1";
    networkmanager.enable = true;
    interfaces = {
      enp7s0 = { # Replace with your actual network interface
        useDHCP = false;
        ipv4.addresses = [{
          address = "192.168.1.165";
          prefixLength = 24;
        }];
      };
    };
    nameservers = [ "192.168.1.1" "8.8.8.8" ];
  };

  # Install NVIDIA drivers and configure Docker to use NVIDIA runtime
  services.xserver.videoDrivers = [ "nvidia" ];

  hardware.opengl = {
    enable = true;
    driSupport = true;
    driSupport32Bit = true;
  };

  # Firewall configuration (example: allow SSH and Docker ports)
  networking.firewall.allowedTCPPorts = [ 22 2376 2377 7946 4789 ];

  # TODO : Add home manager but only the terminal part ( need to be fully done for personnal computer part)

  # TODO: make a core config that is imported automatically for following settings
  # Configure console keymap
  # # Enable sound with pipewire.
  # sound.enable = true;
  # hardware.pulseaudio.enable = false;
  # security.rtkit.enable = true;
  # services.pipewire = {
  #   enable = true;
  #   alsa.enable = true;
  #   alsa.support32Bit = true;
  #   pulse.enable = true;
  #   # If you want to use JACK applications, uncomment this
  #   #jack.enable = true;
  #
  #   # use the example session manager (no others are packaged yet so this is enabled by default,
  #   # no need to redefine it in your config for now)
  #   #media-session.enable = true;
  # };
  # Disable auto-suspend in GDM
  # services.xserver.displayManager.gdm.autoSuspend = false;

  # Keep power management enabled, but prevent sleep and hibernate
  # powerManagement.enable = true;
  # systemd.targets.sleep.enable = false;
  # systemd.targets.suspend.enable = false;
  # systemd.targets.hibernate.enable = false;
  # systemd.targets.hybrid-sleep.enable = false;

  # Enable thermal management
  # services.thermald.enable = true;
}

