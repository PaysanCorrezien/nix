{
  config,
  pkgs,
  lib,
  ...
}:
let
  cfg = config.settings.yubikey;
in
{
  options.settings.yubikey = lib.mkOption {
    type = lib.types.submodule {
      options.enable = lib.mkOption {
        type = lib.types.bool;
        default = false;
      };
    };
  };

  config = lib.mkIf cfg.enable {
    # Basic YubiKey packages
    environment.systemPackages = with pkgs; [
      # YubiKey management tools
      yubikey-manager
      yubikey-manager-qt # GUI tool
      yubikey-personalization
      yubioath-flutter # Authenticator app
      pam_u2f # For U2F support

      pinentry
    ];

    # Enable smart card support
    services.pcscd.enable = true;

    # udev rules for YubiKey
    services.udev.packages = with pkgs; [
      yubikey-personalization
      libu2f-host
    ];

    # Configure PAM for U2F support
    security.pam.u2f = {
      enable = true;
      cue = true; # Show a cue when waiting for YubiKey touch
    };
  };
}
