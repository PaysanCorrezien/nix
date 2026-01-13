{
  config,
  lib,
  ...
}:

{
  settings = {
    username = "dylan";
    isServer = true;
    locale = "fr_FR.UTF-8";
    environment = "home";
    isExperimental = false;
    work = false;
    gaming = false;
    tailscale.enable = true;
    windowManager = null;
    displayServer = null;
    social.enable = false;
    architecture = "x86_64";
    hostname = "ionos";
    docker.enable = false;
    autoSudo = true;
    sops = {
      enable = true;
      enableGlobal = true;
      machineType = "vps";
    };
    disko = {
      mainDisk = "/dev/sda";
      layout = "standard";
    };
    ssh.enable = false; # Disable until a host key is added in hosts/keys.
  };

  users.users.${config.settings.username} = {
    hashedPassword = "$6$.NL5Jii4wwztUzFC$pOiZJ3I2810HLcCZc0CYR5YGEHS6JWibJ75mbx4TWcm0gsxuEAsSK4rsDxu1Ny7o67..V4hdX3mwJQ4enHCJ6.";
    group = "dylan";
    home = "/home/${config.settings.username}";
  };

  users.groups.dylan = { };
  security.sudo.wheelNeedsPassword = false;
}
