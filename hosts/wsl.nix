# hosts/WSL.nix
{ config, lib, pkgs, inputs, ... }:
{
  # WSL module is imported via modules/imports/wsl.nix

  wsl = {
    enable = true;
    defaultUser = "dylan";
    # nativeSystemd removed - now always enabled by default
    usbip.enable = true;
    startMenuLaunchers = true;
    wslConf = {
      automount.enabled = true;
      network.hostname = "wsl";
      interop = {
        enabled = true;
        appendWindowsPath = true;
      };
    };
  };
  wsl.interop = {
    includePath = true;
    register = true;
  };
  services.udev.enable = lib.mkForce true;

  services.openssh.enable = lib.mkForce false;
  # Disable GUI-related services in WSL
  services.xserver.enable = false;
  services.pipewire.enable = false;

  # Disable unnecessary systemd services
  # systemd.services."systemd-timesyncd".enable = false;
  # systemd.services."systemd-udevd".enable = false;
  # services.timesyncd.enable = false;

  boot.isContainer = true;
  powerManagement.enable = lib.mkForce false;
  systemd.user.services.dbus = {
    wantedBy = [ "default.target" ];
  };

  # Allow users to use D-Bus
  security.polkit.enable = true;

  # Force boot loader configurations to be disabled in WSL
  boot.loader.grub.enable = lib.mkForce false;
  boot.loader.systemd-boot.enable = lib.mkForce false;

  settings = {
    username = "dylan";
    isServer = false;
    isWSL = true;
    locale = "fr_FR.UTF-8";
    virtualisation.enable = false;
    docker.enable = true; # Set to false to disable docker and save space
    environment = "work";
    isExperimental = false;
    work = false;
    gaming = false;
    tailscale.enable = false;
    windowManager = null;
    displayServer = null;
    social.enable = false;
    architecture = "x86_64";
    autoSudo = false;
    hostname = "wsl";
    disko.mainDisk = "/dev/sda";
    sops = {
      enable = false;
      enableGlobal = false;
      machineType = "desktop";
    };
  };

  programs = {
    dconf.enable = false;
  };

  # Core WSL packages (always needed)
  environment.systemPackages = with pkgs; [
    dbus
    socat
    wslu
  ] ++ lib.optionals config.settings.docker.enable [
    docker
    docker-compose
    lazydocker
  ];

  # Docker - conditional on settings
  virtualisation.docker = lib.mkIf config.settings.docker.enable {
    enable = true;
    enableOnBoot = true;
  };
  # boot.kernelModules = [ "usbip-core" "vhci-hcd" ];
  boot.extraModulePackages = with config.boot.kernelPackages; [ usbip ];
  programs.zsh = {
  enable = true;
  shellAliases = {
    sudo = "/run/wrappers/bin/sudo";
  };
};

  users.users.dylan = {
    extraGroups = [ "wheel" ] ++ lib.optionals config.settings.docker.enable [ "docker" ];
  };

  # Home-manager now uses conditional imports based on isWSL setting
  # (see modules/home-manager/home.nix)

  systemd.services.polkit.enable = true;
  security.sudo.wheelNeedsPassword = false;

  # Add SSH agent socket configuration
  environment.variables.SSH_AUTH_SOCK = "/mnt/wsl/ssh-agent.sock";

  # SSH agent proxy service for Windows SSH agent integration
  systemd.user.services.ssh-agent-proxy = {
    description = "Windows SSH agent proxy";

    path = [ pkgs.wslu pkgs.coreutils pkgs.bash ];

    serviceConfig = {
      ExecStartPre = [
        "${pkgs.coreutils}/bin/mkdir -p /mnt/wsl"
        "${pkgs.coreutils}/bin/rm -f /mnt/wsl/ssh-agent.sock"
      ];

      ExecStart = "${pkgs.writeShellScript "ssh-agent-proxy" ''
        set -x  # Enable debug output

        # Get Windows username using wslvar
        WIN_USER="$(${pkgs.wslu}/bin/wslvar USERNAME 2>/dev/null || echo $USER)"

        # Check common npiperelay locations
        NPIPE_PATHS=(
          "/mnt/c/Users/$WIN_USER/AppData/Local/Microsoft/WinGet/Packages/jstarks.npiperelay_Microsoft.Winget.Source_8wekyb3d8bbwe/npiperelay.exe"
          "/mnt/c/Users/$WIN_USER/AppData/Local/Microsoft/WinGet/Links/npiperelay.exe"
          "/mnt/c/ProgramData/chocolatey/bin/npiperelay.exe"
        )

        NPIPE_PATH=""
        for path in "''${NPIPE_PATHS[@]}"; do
          echo "Checking npiperelay at: $path"
          if [ -f "$path" ]; then
            NPIPE_PATH="$path"
            break
          fi
        done

        if [ -z "$NPIPE_PATH" ]; then
          echo "npiperelay.exe not found in expected locations!"
          exit 1
        fi

        echo "Using npiperelay from: $NPIPE_PATH"

        exec ${pkgs.socat}/bin/socat -d UNIX-LISTEN:/mnt/wsl/ssh-agent.sock,fork,mode=600 \
          EXEC:"$NPIPE_PATH -ei -s //./pipe/openssh-ssh-agent",nofork
      ''}";
      Type = "simple";
      Restart = "always";
      RestartSec = "5";
      StandardOutput = "journal";
      StandardError = "journal";
      RuntimeDirectory = "ssh-agent";
    };

    wantedBy = [ "default.target" ];
  };

}
