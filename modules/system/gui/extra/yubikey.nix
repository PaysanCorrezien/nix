#TODO: use LUKS and YubiKey for disk encryption instead of login
{
  config,
  pkgs,
  lib,
  ...
}:
let
  cfg = config.settings.yubikey;
  yubiKeyPrimary = "/run/secrets/yubikey/primary";
  yubiKeyBackup = "/run/secrets/yubikey/backup";
  # Helper function to check if both keys are available
  hasYubiKeys = builtins.pathExists yubiKeyPrimary && builtins.pathExists yubiKeyBackup;
in
{
  config = lib.mkIf cfg.enable {
    # Basic YubiKey packages
    environment.systemPackages = with pkgs; [
      yubikey-manager
      yubikey-personalization
      yubioath-flutter
      pam_u2f
      pinentry-gnome3
    ];

    # Enable smart card support
    services.pcscd.enable = true;

    # udev rules for YubiKey
    services.udev.packages = with pkgs; [
      yubikey-personalization
      libu2f-host
    ];

    # NOTE: yubikey need to be set to preserve newline in sops yaml file so we can have one key per line
    # yubikey : |
    #    value
    system.activationScripts.yubikey-setup = ''
      mkdir -p /etc/yubikey
      if [ -f "${yubiKeyPrimary}" ] && [ -f "${yubiKeyBackup}" ]; then
        # Ensure each key is on its own line
        cat ${yubiKeyPrimary} > /etc/yubikey/u2f_keys
        cat ${yubiKeyBackup} >> /etc/yubikey/u2f_keys
        chmod 644 /etc/yubikey/u2f_keys
      fi
    '';
    # Configure PAM for U2F support
    security.pam.u2f = {
      enable = true;
      settings = {
        cue = true;
        interactive = true;
        authfile = "/etc/yubikey/u2f_keys";
      };
      # Only require YubiKey if both keys are available
      control = if hasYubiKeys then "required" else "sufficient";
    };

    # Enable U2F auth for services
    security.pam.services = lib.mkIf hasYubiKeys {
      login.u2fAuth = true;
      sddm.u2fAuth = true;
      sudo.u2fAuth = true;
    };
  };
}
