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
    tailscaleIP = "100.100.110.30";
    hostname = "ionos";
    ai.server.enable = false;
    sops = {
      #NOTE: from sops.nix file 
      enableGlobal = true;
      machineType = "vps"; # or "homeserver" or "vps"
    };

  };

  services.openssh = {
    enable = true;
    settings = {
      PasswordAuthentication = false;
      PermitRootLogin = "no";
      KbdInteractiveAuthentication = false;
      X11Forwarding = false;
      AuthenticationMethods = "publickey";
      UsePAM = false;
    };
    extraConfig = ''
      AllowUsers ${config.settings.username}
      PubkeyAuthentication yes
      AllowTcpForwarding no
      AllowAgentForwarding no
      MaxAuthTries 10
    '';
  };

  users.users.${config.settings.username} = {
    openssh.authorizedKeys.keyFiles =
      [ "${inputs.self}/hosts/keys/${config.settings.hostname}.pub" ];
  };
}

