{ lib, config, pkgs, ... }:
let
  username = "dylan";
  isServer = config.settings.isServer;
  defaultGuiEnable = !isServer; # Default to true if not a server
in {
  imports = [
    ./dev/python.nix
    ./programs/espanso.nix
    ./programs/thunderbird.nix
    ./extra/work.nix
    ./extra/audio.nix
    ./extra/social.nix
    ./extra/virtualisation.nix
    ./extra/glance.nix
    ./extra/gnome.nix
    ./extra/ollama.nix
    ./extra/clovis.nix
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

      services.xserver.enable = true;
      services.xserver.desktopManager.gnome.enable = true;
      services.displayManager.sddm = {
        enable = true;
        wayland.enable = false;
        theme = "catppuccin-mocha";
        package = pkgs.kdePackages.sddm;
        # extraPackages = with pkgs; [ catppucin-sddm ];
        autoNumlock = true;
      };
      # environment.systemPackages = [
      # ];

      hardware.pulseaudio.enable = false;

      # Enable sound with pipewire.
      security.rtkit.enable = true;
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
        # wezterm
        todoist-electron
        rofi
        obsidian
        libnotify
        todoist
        flameshot
        #flameshot need FIXME: for wayland launch via shortcut or find how to add to gnome allow list of app https://flameshot.org/docs/guide/wayland-help/
        (pkgs.catppuccin-sddm.override {
          flavor = "mocha";
          font = "Noto Sans";
          fontSize = "9";
          background =
            "${../../home-manager/gnome/backgrounds/wallpaper_leaves.png}";
          loginBackground = true;
          # ClockEnabled = true;
        })
        xdg-desktop-portal-gnome
        xdg-desktop-portal

      ];

      # NOTE: TODOIST 
      nixpkgs.config.permittedInsecurePackages = [ "electron-25.9.0" ];

      # Enable the OpenSSH daemon.
      services.openssh.enable = true;
    })
  ];
}

