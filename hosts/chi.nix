{ inputs, config, pkgs, lib, ... }:

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
    hostname = "chi";
    docker.enable = false;
    sops = {
      #NOTE: from sops.nix file 
      enable = true;
      enableGlobal = true;
      machineType = "vps"; # or "homeserver" or "vps"
    };
    disko = {
        mainDisk = "/dev/sda";
        layout = "standard";
    };

  };
  users.users.${config.settings.username} = {
    # initialPassword = "dylan"; #TODO: put pass in sops as users.users.your-user.initialHashedPassword 
    hashedPassword = "$6$.NL5Jii4wwztUzFC$pOiZJ3I2810HLcCZc0CYR5YGEHS6JWibJ75mbx4TWcm0gsxuEAsSK4rsDxu1Ny7o67..V4hdX3mwJQ4enHCJ6."; # dylan for test

    group = "dylan";
    home = "/home/${config.settings.username}";
  };
  users.groups.dylan = { };
  security.sudo.wheelNeedsPassword = false;
}


