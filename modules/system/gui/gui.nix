{ lib, config, pkgs, ... }:
let
  username = "dylan";
  isServer = config.settings.isServer;
  defaultGuiEnable = !isServer; # Default to true if not a server
in {
  imports = [
    ./extra/virtualisation.nix
    ./dev/python.nix
    ./programs/thunderbird.nix
    # ../home-manager/gnome/keybinds.nix
  ];

  options.settings.gui = {
    enable = lib.mkEnableOption
      "Enable the GUI interface and all the related settings";
  };

  config = lib.mkMerge [
    { settings.gui.enable = lib.mkDefault defaultGuiEnable; }
    (lib.mkIf config.settings.gui.enable {
      # Enable automatic login for the user.
      services.displayManager.autoLogin.enable = true;
      services.displayManager.autoLogin.user = "dylan";

      services.xserver.enable = true;
      services.xserver.desktopManager.gnome.enable = true;
      services.xserver.displayManager.lightdm.enable = true;

      services.xserver = {
        xkb.layout = "fr,us";
        xkb.variant = ",altgr-intl";
        # xkb.options = "grp:alt_shift_toggle"; # Use Alt+Shift to switch between layouts
      };

      # Workaround for GNOME autologin: https://github.com/NixOS/nixpkgs/issues/103746#issuecomment-945091229
      systemd.services."getty@tty1".enable = false;
      systemd.services."autovt@tty1".enable = false;

      services.espanso.enable = true;
      sound.enable = true;
      hardware.pulseaudio.enable = false;

      # Enable sound with pipewire.
      services.pipewire = {
        enable = true;
        alsa.enable = true;
        alsa.support32Bit = true;
        pulse.enable = true;
        # If you want to use JACK applications, uncomment this
        #jack.enable = true;
      };

      services.printing.enable = true;

      environment.systemPackages = with pkgs; [
        helix
        wezterm
        todoist-electron
        rofi
        obsidian
        discord
        libnotify
        espanso
        todoist
        flameshot
        microsoft-edge
        linphone
        openfortivpn
        remmina
        wireshark
        teamviewer
      ];

      # NOTE: TODOIST 
      nixpkgs.config.permittedInsecurePackages = [ "electron-25.9.0" ];

      # Enable the OpenSSH daemon.
      services.openssh.enable = true;
    })
  ];
}

