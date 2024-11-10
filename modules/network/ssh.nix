{
  inputs,
  config,
  pkgs,
  lib,
  ...
}:
let
  cfg = config.settings.ssh;
in
{
  options.settings = lib.mkOption {
    type = lib.types.submodule {
      options.ssh = lib.mkOption {
        type = lib.types.submodule {
          options = {
            enable = lib.mkEnableOption "Enable SSHD custom hardened configuration";
          };
        };
        default = {
          enable = true;
        };
        description = "SSHD settings";
      };
    };
  };

  config = lib.mkIf cfg.enable {
    services.openssh = {
      enable = true;
      settings = {
        PasswordAuthentication = false;
        PermitRootLogin = "no";
        KbdInteractiveAuthentication = false;
        X11Forwarding = false;
        AuthenticationMethods = "publickey";
        AuthorizedPrincipalsFile = "none";
        UsePAM = false;
        PermitEmptyPasswords = false;
        Ciphers = [
          "chacha20-poly1305@openssh.com"
          "aes256-gcm@openssh.com"
          "aes128-gcm@openssh.com"
          "aes256-ctr"
          "aes192-ctr"
          "aes128-ctr"
        ];
        Macs = [
          "hmac-sha2-512-etm@openssh.com"
          "hmac-sha2-256-etm@openssh.com"
          "umac-128-etm@openssh.com"
        ];
        KexAlgorithms = [
          "curve25519-sha256"
          "curve25519-sha256@libssh.org"
          "diffie-hellman-group16-sha512"
          "diffie-hellman-group18-sha512"
        ];
      };
      extraConfig = ''
        AllowUsers ${config.settings.username}
        PubkeyAuthentication yes
        AllowTcpForwarding no
        AllowAgentForwarding no
        MaxAuthTries 10
        PermitUserEnvironment no
        Protocol 2
      '';
    };

    users.users.${config.settings.username} = {
      openssh.authorizedKeys.keyFiles = [ "${inputs.self}/hosts/keys/${config.settings.hostname}.pub" ];
    };
  };
}
