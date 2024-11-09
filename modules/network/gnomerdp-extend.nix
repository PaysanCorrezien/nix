{
  config,
  lib,
  pkgs,
  ...
}:
{
  options = {
    services.gnome.gnome-remote-desktop = {
      enable = lib.mkEnableOption "Remote Desktop support using Pipewire";

      settings = lib.mkOption {
        type = lib.types.attrs;
        default = { };
        description = ''
          GNOME Remote Desktop settings.
        '';
      };

      username = lib.mkOption {
        type = lib.types.str;
        description = ''
          Username for RDP connection authentication.
          This is just for RDP access and doesn't need to match your system username.
          After RDP authentication, you'll connect to your actual user session.
        '';
      };

      password = lib.mkOption {
        type = lib.types.str;
        description = ''
          Password for RDP connection authentication.
          This is separate from your system user password and is only used for RDP access.
          You may still need to unlock your session with your actual user password.
        '';
      };

      generateCerts = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = ''
          Whether to automatically generate TLS certificates for RDP.
          If disabled, you'll need to provide your own certificates.
        '';
      };
    };
  };

  config = lib.mkIf config.services.gnome.gnome-remote-desktop.enable {
    services.pipewire.enable = true;
    services.dbus.packages = [ pkgs.gnome-remote-desktop ];
    environment.systemPackages = [
      pkgs.gnome-remote-desktop
      pkgs.freerdp # For winpr-makecert
    ];
    systemd.packages = [ pkgs.gnome-remote-desktop ];
    systemd.tmpfiles.packages = [ pkgs.gnome-remote-desktop ];

    users = {
      users.gnome-remote-desktop = {
        isSystemUser = true;
        group = "gnome-remote-desktop";
        home = "/var/lib/gnome-remote-desktop";
      };
      groups.gnome-remote-desktop = { };
    };

    systemd.services.gnome-remote-desktop = {
      serviceConfig = {
        StateDirectory = "gnome-remote-desktop";
        StateDirectoryMode = "0700";
      };
      preStart =
        let
          certScript = lib.optionalString config.services.gnome.gnome-remote-desktop.generateCerts ''
            # Generate certificates if they don't exist
            if [ ! -f /var/lib/gnome-remote-desktop/rdp-tls.key ]; then
              ${pkgs.freerdp}/bin/winpr-makecert \
                -silent \
                -rdp \
                -path /var/lib/gnome-remote-desktop \
                rdp-tls
              chown gnome-remote-desktop:gnome-remote-desktop /var/lib/gnome-remote-desktop/rdp-tls.*
            fi

            ${pkgs.gnome-remote-desktop}/bin/grdctl --system rdp set-tls-key /var/lib/gnome-remote-desktop/rdp-tls.key
            ${pkgs.gnome-remote-desktop}/bin/grdctl --system rdp set-tls-cert /var/lib/gnome-remote-desktop/rdp-tls.crt
          '';
        in
        ''
          # Ensure directory exists with proper permissions
          mkdir -p /var/lib/gnome-remote-desktop
          chown gnome-remote-desktop:gnome-remote-desktop /var/lib/gnome-remote-desktop

          # Setup RDP
          ${pkgs.gnome-remote-desktop}/bin/grdctl --system rdp enable
          ${pkgs.gnome-remote-desktop}/bin/grdctl --system rdp set-credentials "${config.services.gnome.gnome-remote-desktop.username}" "${config.services.gnome.gnome-remote-desktop.password}"

          ${certScript}
        '';
    };
  };
}
