# hosts/lenovo.nix
{ config, pkgs, inputs, ... }:

{
  imports = [
    ./gnome/extensions.nix
    ./gnome/settings.nix
    ./browser/firefox.nix
    inputs.home-manager.nixosModules.home-manager
  ];

  networking.hostName = "lenovo";
  
  # boot.loader.grub.device = "/dev/sda"; # Adjust as needed

  # Host-specific configurations
  services.xserver.displayManager.lightdm.background = "/home/dylan/.config/nixos/modules/home-manager/gnome/backgrounds/wallpaper_leaves.png";
  services.xserver.desktopManager.gnome.enable = true;
  services.xserver.enable = true;

  # Other host-specific settings

# TODO: move to gnome.nix
   # Enable the GNOME Desktop Environment.
  services.xserver.displayManager.gdm.enable = false;

    # Enable LightDM
  services.xserver.displayManager.lightdm.enable = true;
  services.xserver.displayManager.lightdm = {
    enable = true;
        background = "/home/dylan/.config/nixos/modules/home-manager/gnome/backgrounds/wallpaper_leaves.png";  # Set the background image
    greeters = {
      #gtk = {
        # theme = "Catppuccin-Macchiato-Compact-Pink-Dark";  # This should be a valid GTK theme name
    #    iconTheme = "Papirus";  # Set the icon theme, if "Papirus" is installed
     #   fontName = "Noto Sans 10";  # Set the font and size for the greeter
     # };
    };
  };

  # Enable automatic login for the user.
  services.displayManager.autoLogin.enable = true;
  services.displayManager.autoLogin.user = "dylan";
  # Workaround for GNOME autologin: https://github.com/NixOS/nixpkgs/issues/103746#issuecomment-945091229
  systemd.services."getty@tty1".enable = false;
  systemd.services."autovt@tty1".enable = false;

}

