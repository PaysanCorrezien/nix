{ lib, config, pkgs, ... }:

let
  username = "dylan";
  isServer = config.settings.isServer;
  isWSL = config.wsl.enable or false;
  defaultGuiEnable = !(isServer || isWSL); # Default to false if server or WSL
in
{
  imports = [
    ./dev/python.nix
    ./dev/pwsh.nix
    ./programs/espanso.nix
    ./extra/work.nix
    ./extra/audio.nix
    ./extra/social.nix
    ./extra/virtualisation.nix
    ./extra/glance.nix
    ./extra/gnome.nix
    ./extra/ollama.nix
    ./extra/screensaver.nix
    ./extra/clovis.nix
    ./extra/keybswitch.nix
    ./extra/kde.nix
    ./extra/tablet.nix
  ];

  options.settings.gui = {
    enable = lib.mkEnableOption
      "Enable the GUI interface and all the related settings";
  };

  config = lib.mkMerge [
    { settings.gui.enable = lib.mkDefault defaultGuiEnable; }
    (lib.mkIf config.settings.gui.enable {
      # Enable X server only if display server is not null
      services.xserver.enable = config.settings.displayServer != null;

      # Configure display manager based on settings
      services.displayManager =
        lib.mkIf (config.settings.windowManager != null) {
          sddm = {
            enable = true;
            wayland.enable = config.settings.displayServer == "wayland";
            theme = "catppuccin-mocha";
            # package = pkgs.kdePackages.sddm;
            package = lib.mkForce pkgs.kdePackages.sddm;
            autoNumlock = true;
            settings = {
              General = {
                DisplayServer =
                  if config.settings.displayServer == "wayland" then
                    "wayland"
                  else
                    "x11";
              };
            };
          };
        };

      # Enable GNOME desktop manager if windowManager is set to "gnome"
      services.xserver.desktopManager.gnome.enable =
        config.settings.windowManager == "gnome";

      # Enable KDE desktop manager if windowManager is set to "kde"
      services.xserver.desktopManager.plasma6.enable =
        config.settings.windowManager == "plasma";

      hardware.pulseaudio.enable = false;

      # Enable sound with pipewire.
      security.rtkit.enable = true;
      services.pipewire = {
        enable = true;
        alsa.enable = true;
        alsa.support32Bit = true;
        pulse.enable = true;
      };

      services.printing.enable = true;
      services.usbmuxd.enable = true;

      environment.systemPackages = with pkgs; [
      #TODO: move these programs
        helix
        zed-editor
        todoist-electron
        rofi
        obsidian #TODO: boostrap obsidian
        libnotify
        gimp-with-plugins
        todoist
        flameshot
        libimobiledevice
        ifuse
        (pkgs.catppuccin-sddm.override {
          flavor = "mocha";
          font = "Noto Sans";
          fontSize = "9";
          background =
            "${../../home-manager/gnome/backgrounds/wallpaper_leaves.png}";
          loginBackground = true;
        })
        xdg-desktop-portal-gnome
        xdg-desktop-portal
      ];

      # NOTE: TODOIST 
      nixpkgs.config.permittedInsecurePackages = [ "electron-25.9.0" ];

      # wake from sleep for main computer
      services.udev.extraRules = ''
        ACTION=="add", SUBSYSTEM=="usb", ATTRS{removable}=="removable", ATTR{power/wakeup}="enabled"
        ACTION=="add", SUBSYSTEM=="usb", ATTRS{removable}=="fixed", ATTR{power/wakeup}="enabled"
      '';
      boot.kernelParams = [ "usbcore.autosuspend=-1" ];
      powerManagement.enable = true;
      powerManagement.powertop.enable = true;

      # Enable the OpenSSH daemon.
      # services.openssh.enable = true;
    })
  ];
}
