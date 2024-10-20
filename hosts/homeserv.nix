{ inputs, config, pkgs, ... }:

{
  settings = {
    username = "dylan";
    isServer = true;
    locale = "fr_FR.UTF-8";
    # virtualisation.enable = true;
    environment = "home";
    isExperimental = false;
    work = false;
    gaming = false;
    tailscale.enable = true;
    windowManager = null;
    displayServer = null;
    social.enable = false;
    architecture = "x86_64";
    hostname = "homeserv";
    docker.enable = true;
    autoSudo = true;
    sops = {
      #NOTE: from sops.nix file 
      enable = true;
      enableGlobal = true;
      machineType = "homeserver"; # or "homeserver" or "vps"
    };
     disko = {
        mainDisk = "/dev/sda";
        layout = "standard";
    };


  };

  imports = [
    (./. + "/specific-confs/music-sync.nix")
];
  # Configure static IP dynamically
  networking = {
    defaultGateway.interface = "enp7s0";
    defaultGateway.address = "192.168.1.1";
    networkmanager.enable = true;

    # : allow SSH and Docker ports
    firewall.allowedTCPPorts = [
      22
      2376
      2377
      7946
      4789
      # duplicati 
      # TODO: move this to a random port
      8200
    ];
    interfaces = {
      enp7s0 = {
        # Replace with your actual network interface
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

   hardware.graphics.enable = true;
   hardware.graphics.enable32Bit = true;
   hardware.nvidia-container-toolkit.enable = true;
    hardware.nvidia = {
    modesetting.enable = true;
    open = false;
    nvidiaSettings = true;
    package = config.boot.kernelPackages.nvidiaPackages.production;
  };

  services.duplicati = {
    enable = true;
    port = 8200;
    interface = "any";
    # dataDirectory = "/var/lib/duplicati";
    #NOTE: testing if running as user is fine
    user = config.settings.username;
  };
  # TODO : Add home manager but only the terminal part ( need to be fully done for personnal computer part)


  environment.systemPackages = with pkgs; [
    davfs2 # webdav
    rclone
    hdparm #DISK management/wake
    ntfs3g
    jq
  ];
  services.davfs2 = {
    enable = true;
  };
}


