{ inputs, config, pkgs, ... }:
{

  config = lib.mkIf cfg.enable {
    settings = {
      username = "dylan";
      isServer = true;
      locale = "fr_FR.UTF-8";
      environment = "home";
      isExperimental = false;
      work = false;
      gaming = false;
      tailscale.enable = true;
      windowManager = "none";
      displayServer = "xorg";
      social.enable = false;
      architecture = "x86_64";
      hostname = "remote";
      docker.enable = false;
      sops = {
        enable = true;
        enableGlobal = true;
        machineType = "desktop";
      };
      disko = {
        mainDisk = "/dev/sda";
        layout = "standard";
      };
    };

    users.users.${config.settings.username} = {
      hashedPassword = "$6$.NL5Jii4wwztUzFC$pOiZJ3I2810HLcCZc0CYR5YGEHS6JWibJ75mbx4TWcm0gsxuEAsSK4rsDxu1Ny7o67..V4hdX3mwJQ4enHCJ6.";
      packages = [ pkgs.freerdp ];
    };

    # Enable X11 and auto-login
    services.xserver = {
      enable = true;
      displayManager = {
        autoLogin = {
          enable = true;
          user = config.settings.username;
        };
        defaultSession = "rdp";
      };
    };

    # Create the RDP session
    system.activationScripts.rdpSession = ''
      mkdir -p /usr/share/xsessions
      cat > /usr/share/xsessions/rdp.desktop << EOF
      [Desktop Entry]
      Name=RDP Session
      Exec=${pkgs.writeShellScript "start-rdp" ''
        #!/bin/sh
        ${pkgs.freerdp}/bin/xfreerdp /v:workstation /u:dylan /p: /f
      ''}
      Type=Application
      EOF
    '';

    # Install necessary packages
    environment.systemPackages = [ pkgs.freerdp ];

    # Create user
    users.users.dylan = {
      isNormalUser = true;
      extraGroups = [ "wheel" ];
    };

    # Disable unused services
    services.xserver.desktopManager.gnome.enable = false;
    services.xserver.windowManager = { };
  };
}
