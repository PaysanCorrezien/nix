{
  lib,
  config,
  pkgs,
  ...
}:

let
  username = "dylan";
  isServer = config.settings.isServer;
  isWSL = config.wsl.enable or false;
  defaultGuiEnable = !(isServer || isWSL); # Default to false if server or WSL
in
{
  imports = [
    ./dev/python.nix
    ./programs/espanso.nix
    ./extra/work.nix
    ./extra/audio.nix
    ./extra/social.nix
    # ./extra/virtualisation.nix
    ./extra/glance.nix
    ./extra/gnome.nix
    ./extra/hyprland.nix
    ./extra/stylix.nix
    ./extra/docker.nix
    ./extra/screensaver.nix
    ./extra/clovis.nix
    ./extra/keybswitch.nix
    ./extra/tablet.nix
    ./extra/yubikey.nix
  ];

  options.settings.gui = {
    enable = lib.mkEnableOption "Enable the GUI interface and all the related settings";
  };

  config = lib.mkMerge [
    { settings.gui.enable = lib.mkDefault defaultGuiEnable; }
    (lib.mkIf config.settings.gui.enable {
      # Enable X server only if display server is not null
      services.xserver.enable = config.settings.displayServer != null;

      # Configure display manager based on settings
      services.displayManager = lib.mkIf (config.settings.windowManager != null) {
        sddm = {
          enable = true;
          wayland.enable = config.settings.displayServer == "wayland";
          theme = "catppuccin-mocha";
          package = lib.mkForce pkgs.kdePackages.sddm;
          autoNumlock = true;
          settings = {
            General = {
              DisplayServer = if config.settings.displayServer == "wayland" then "wayland" else "x11";
            };
          };
        };
      };

      # Enable GNOME desktop manager if windowManager is set to "gnome"
      services.xserver.desktopManager.gnome.enable = config.settings.windowManager == "gnome";

      # Enable KDE desktop manager if windowManager is set to "kde"
      services.desktopManager.plasma6.enable = config.settings.windowManager == "plasma";

      # Enable Hyprland if windowManager is set to "hyprland"
      programs.hyprland.enable = config.settings.windowManager == "hyprland";

      hardware.pulseaudio.enable = false;

      # Enable sound with pipewire.
      security.rtkit.enable = true;
      services.pipewire = {
        enable = true;
        alsa.enable = true;
        alsa.support32Bit = true;
        pulse.enable = true;
      };

      services.printing = {
        enable = true;
        drivers = [ pkgs.gutenprint ];
      };
      services.usbmuxd.enable = true;

      environment.systemPackages = with pkgs; [
        # TODO: move these programs
        helix
        # zed-editor
        # todoist-electron
        # rofi
        wofi
        pnpm # TODO: create a web.nix
        obsidian # TODO: boostrap obsidian
        libnotify
        gimp-with-plugins
        todoist
        flameshot
        libimobiledevice
        mullvad
        localsend
        activitywatch
        ifuse
        (pkgs.catppuccin-sddm.override {
          flavor = "mocha";
          font = "Noto Sans";
          fontSize = "9";
          background = "${../../home-manager/gnome/backgrounds/wallpaper_leaves.png}";
          loginBackground = true;
        })
        xdg-desktop-portal-gnome
        xdg-desktop-portal
      ];
      services.mullvad-vpn.package = pkgs.mullvad-vpn;
      services.mullvad-vpn.enable = true;

      services.udev.extraRules = ''
        # Only enable wakeup for devices that support it
        ACTION=="add", SUBSYSTEM=="usb", TEST=="power/wakeup", ATTR{power/wakeup}="enabled"
      '';
      boot.kernelParams = [ "usbcore.autosuspend=-1" ];
      powerManagement.enable = true;
      powerManagement.powertop.enable = true;

    })
  ];
}
