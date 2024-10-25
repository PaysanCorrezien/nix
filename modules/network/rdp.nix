{ config, lib, pkgs, ... }:

let
  cfg = config.settings.rdpserver;
  xrdpScript = pkgs.writeScript "startwm.sh" ''
    #!/bin/sh
    exec &> /tmp/xrdp-session-$USER.log
    set -x

    . /etc/profile
    export DISPLAY=:10.0
    export XAUTHORITY="/home/${config.settings.username}/.Xauthority"

    # Debug information
    echo "Environment variables:"
    env

    echo "Contents of /run/current-system/sw/bin:"
    ls -l /run/current-system/sw/bin

    # Try to start a basic X session
    if command -v startx >/dev/null 2>&1; then
      echo "Starting X session with startx"
      exec startx
    elif command -v xinit >/dev/null 2>&1; then
      echo "Starting X session with xinit"
      exec xinit -- :10
    else
      echo "Neither startx nor xinit found. Falling back to SDDM"
      exec /run/current-system/sw/bin/sddm-greeter
    fi
  '';
in
{
  options.settings.rdpserver = {
    enable = lib.mkEnableOption "Enable RDP on the host (via Tailscale only)";
  };
  config = lib.mkMerge [
    (lib.mkIf cfg.enable {
      services.xrdp = {
        enable = true;
        openFirewall = false;
        defaultWindowManager = "${xrdpScript}";
        extraConfDirCommands = ''
          cp ${xrdpScript} $out/startwm.sh
          chmod +x $out/startwm.sh
          substituteInPlace $out/xrdp.ini \
            --replace "LogLevel=INFO" "LogLevel=DEBUG" \
            --replace "LogFile=/dev/null" "LogFile=/var/log/xrdp/xrdp.log"
          substituteInPlace $out/sesman.ini \
            --replace "LogLevel=INFO" "LogLevel=DEBUG" \
            --replace "LogFile=/dev/null" "LogFile=/var/log/xrdp/sesman.log"
        '';
      };

      # Allow RDP through Tailscale interface only
      networking.firewall = {
        interfaces."tailscale0".allowedTCPPorts = [ 3389 ];
      };

      # Ensure necessary groups for the user
      users.users = lib.mkIf (config.settings.username != null) {
        ${config.settings.username}.extraGroups = [ "audio" "video" "input" ];
      };

      # Ensure log directory exists and is writable
      systemd.tmpfiles.rules = [
        "d /var/log/xrdp 0755 xrdp xrdp -"
      ];

      # Modify the XRDP service to ensure it can write logs
      systemd.services.xrdp = {
        serviceConfig = {
          ExecStartPre = [
            "${pkgs.coreutils}/bin/mkdir -p /var/log/xrdp"
            "${pkgs.coreutils}/bin/chown xrdp:xrdp /var/log/xrdp"
          ];
        };
      };

      # Ensure X11 utilities are available
      environment.systemPackages = with pkgs; [
        xorg.xinit
        xorg.xauth
      ];

      assertions = [
        {
          assertion = config.services.tailscale.enable;
          message = "RDP server requires Tailscale to be enabled. Please enable Tailscale before enabling RDP.";
        }
      ];
    })
    {
      settings.tailscale.tags = lib.mkIf cfg.enable (lib.mkOrder 1500 [ "rdp" ]);
    }
  ];
}
