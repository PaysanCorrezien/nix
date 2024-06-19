# hosts/lenovo.nix
{ config, pkgs, ... }:

{
  networking.hostName = "lenovo";
  
  # boot.loader.grub.device = "/dev/sda"; # Adjust as needed

  # Host-specific configurations
  # services.xserver.displayManager.lightdm.background = "/home/dylan/.config/nixos/modules/home-manager/gnome/backgrounds/wallpaper_leaves.png";
  services.xserver.desktopManager.gnome.enable = true;

  # Other host-specific settings

# TODO: move to gnome.nix
   # Enable the GNOME Desktop Environment.
  services.xserver.displayManager.gdm.enable = false;
  
    environment.systemPackages = with pkgs; [
  acpi # battery util
  ];

    # Enable LightDM
  # services.xserver.displayManager.lightdm = {
  #   enable = true;
        # background = "/home/dylan/.config/nixos/modules/home-manager/gnome/backgrounds/wallpaper_leaves.png";  # Set the background image
    # greeters = {
      #gtk = {
        # theme = "Catppuccin-Macchiato-Compact-Pink-Dark";  # This should be a valid GTK theme name
    #    iconTheme = "Papirus";  # Set the icon theme, if "Papirus" is installed
     #   fontName = "Noto Sans 10";  # Set the font and size for the greeter
     # };
    # };
  # };
}

