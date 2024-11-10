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
        mainDisk = "/dev/sdc";
        layout = "standard";
    };

  };

  imports = [
    (./. + "/specific-confs/music-sync.nix")
    (./. + "/specific-confs/restic.nix")
];
  # Configure static IP dynamically
  networking = {
    defaultGateway.interface = "enp7s0";
    defaultGateway.address = "192.168.1.1";
    networkmanager.enable = false;

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
    boot = {
    supportedFilesystems = [ "acl" ];
    # Any other boot configurations you might have
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
    acl
    restic
  ];

  services.davfs2 = {
    enable = true;
  };
    users.users.${config.settings.username}.extraGroups = [ "postgres" ];

    systemd.tmpfiles.rules = [
    # NOTE: Base Docker directory
    "d /home/${config.settings.username}/docker 0755 ${config.settings.username} users -"

    # NOTE: Critical Services (0700) - Highest security, owner-only access
    # Database and sensitive credentials storage
    "d /home/${config.settings.username}/docker/postgresql/data 0700 ${config.settings.username} users -"
    "d /home/${config.settings.username}/docker/grafana/storage/provisioning 0700 ${config.settings.username} users -"
    "d /home/${config.settings.username}/docker/flowise/data/storage 0700 ${config.settings.username} users -"
    "d /home/${config.settings.username}/docker/immich/database 0750 999 postgres -"


    # NOTE: Sensitive Services (0750) - Restricted group access
    # Services with user data or configuration
    "d /home/${config.settings.username}/docker/grafana 0750 ${config.settings.username} users -"
    "d /home/${config.settings.username}/docker/grafana/storage 0750 ${config.settings.username} users -"
    "d /home/${config.settings.username}/docker/grafana/storage/plugins 0750 ${config.settings.username} users -"
    "d /home/${config.settings.username}/docker/grafana/storage/dashboards 0750 ${config.settings.username} users -"
    "d /home/${config.settings.username}/docker/grafana/storage/logs 0750 ${config.settings.username} users -"
    "d /home/${config.settings.username}/docker/postgresql 0750 ${config.settings.username} users -"
    "d /home/${config.settings.username}/docker/atuin 0750 ${config.settings.username} users -"
    "d /home/${config.settings.username}/docker/loki/data 0750 ${config.settings.username} users -"
    "d /home/${config.settings.username}/docker/flowise/data 0750 ${config.settings.username} users -"
    "d /home/${config.settings.username}/docker/flowise/data/logs 0750 ${config.settings.username} users -"
    "d /home/${config.settings.username}/docker/flowise/data/uploads 0750 ${config.settings.username} users -"
    "d /home/${config.settings.username}/docker/immich 0750 ${config.settings.username} users -"
    "d /home/${config.settings.username}/docker/immich/upload 0750 ${config.settings.username} users -"  
    "d /home/${config.settings.username}/docker/immich/redis 0750 ${config.settings.username} users -"   
    "d /home/${config.settings.username}/docker/postgres-vikunja 0750 ${config.settings.username} users -" 
    
    # NOTE: Standard Services (0755) - Normal access
    # Public-facing and non-sensitive services
    "d /home/${config.settings.username}/docker/freshrss 0755 ${config.settings.username} users -"
    "d /home/${config.settings.username}/docker/prometheus 0755 ${config.settings.username} users -"
    "d /home/${config.settings.username}/docker/alertmanager 0755 ${config.settings.username} users -"
    "d /home/${config.settings.username}/docker/loki 0755 ${config.settings.username} users -"
    "d /home/${config.settings.username}/docker/promtail 0755 ${config.settings.username} users -"
    "d /home/${config.settings.username}/docker/ollama 0755 ${config.settings.username} users -"
    "d /home/${config.settings.username}/docker/ollama/data 0755 ${config.settings.username} users -"
    "d /home/${config.settings.username}/docker/open-webui 0755 ${config.settings.username} users -"
    "d /home/${config.settings.username}/docker/open-webui/data 0755 ${config.settings.username} users -"
    "d /home/${config.settings.username}/docker/navidrome 0755 ${config.settings.username} users -"
    "d /home/${config.settings.username}/docker/navidrome/data 0755 ${config.settings.username} users -"
    "d /home/${config.settings.username}/docker/navidrome/data/cache 0755 ${config.settings.username} users -"
    "d /home/${config.settings.username}/docker/flowise/app 0755 ${config.settings.username} users -"
    "d /home/${config.settings.username}/docker/n8n 0755 ${config.settings.username} users -"
    "d /home/${config.settings.username}/docker/immich/cache 0755 ${config.settings.username} users -"  
    "d /home/${config.settings.username}/docker/vikunja 0755 ${config.settings.username} users -"   

];
  # ACL Configuration Notes:
  # setfacl parameters used below:
  # -R: recursive (apply to all existing files/dirs)
  # -d: default (sets inheritance for new files/dirs)
  # -m: modify the ACL
  # u:user:rwx = user gets read/write/execute
  # g:group:rx = group gets read/execute
# NOTE: ACL Configuration
# Sets default ACLs for inheritance and current permissions
system.activationScripts.dockerDirPermissions = {
    text = ''
      # Set base ACLs for docker directory
      ${pkgs.acl}/bin/setfacl -Rdm u:${config.settings.username}:rwx,g:users:rx /home/${config.settings.username}/docker
      ${pkgs.acl}/bin/setfacl -Rm u:${config.settings.username}:rwx,g:users:rx /home/${config.settings.username}/docker

      # Additional ACLs for critical directories
      ${pkgs.acl}/bin/setfacl -Rm u:${config.settings.username}:rwx,g:users:- /home/${config.settings.username}/docker/postgresql/data
      ${pkgs.acl}/bin/setfacl -Rm u:${config.settings.username}:rwx,g:users:- /home/${config.settings.username}/docker/grafana/storage/provisioning
      ${pkgs.acl}/bin/setfacl -Rm u:${config.settings.username}:rwx,g:users:- /home/${config.settings.username}/docker/flowise/data/storage

      # Immich database ACLs - ensure both postgres and your user have access
      ${pkgs.acl}/bin/setfacl -Rdm u:999:rwx,u:${config.settings.username}:rx /home/${config.settings.username}/docker/immich/database
      ${pkgs.acl}/bin/setfacl -Rm u:999:rwx,u:${config.settings.username}:rx /home/${config.settings.username}/docker/immich/database
      
      # Ensure the parent directory is accessible
      ${pkgs.acl}/bin/setfacl -m u:${config.settings.username}:rx /home/${config.settings.username}/docker/immich
    '';
    deps = [];
};
