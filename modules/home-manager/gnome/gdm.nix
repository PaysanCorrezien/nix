{ config, pkgs, ... }:

{
  # Enable the GNOME Desktop Environment
  services.xserver.displayManager.gdm.enable = true;
  services.xserver.desktopManager.gnome.enable = true;
  # TEST: this 
  # services.xserver.displayManager.sddm = {
  #   enable = true;
  #   # wayland.enable = true;
  #   # theme = "catppuccino-mocha";
  #   # package = pkgs.kdePackages.sddm;
  #   # extraPackages = with pkgs; [ catppucin-sddm ];
  #   autoNumlock = true;
  # };
  # environment.systemPackages = [
  #   (pkgs.catppuccin-sddm.override {
  #     flavor = "mocha";
  #     font = "Noto Sans";
  #     fontSize = "9";
  #     background = "${./backgrounds/wallpaper_leaves.png}";
  #     loginBackground = true;
  #     ClockEnabled = true;
  #   })
  # ];

  #  # Define GDM theming settings, ensuring that they're in a location GDM can use
  #  environment.etc."gdm/greeter.dconf-defaults".source = pkgs.writeText "gdm-greeter-dconf-defaults" ''
  #    [org/gnome/login-screen]
  #    background='file:///home/dylan/.config/nixos/modules/home-manager/gnome/backgrounds/wallpaper_leaves.png'
  #    primary-color='#b7bdf8'  # Lavender
  #    secondary-color='#f0c6c6'  # Flamingo
  #  '';
  #
  #  # Ensure that GDM can read the above settings
  #  # Typically this involves making sure that the GDM process can access these dconf settings
  #  # One way is to ensure the path `/etc/gdm/greeter.dconf-defaults` is read by GDM, which may require
  #  # setting it via GDM's configuration files or systemd service modifications if necessary
  # environment.etc."dconf/profile/gdm".text = ''
  #    user-db:user
  #    system-db:gdm
  #    file-db:/etc/gdm/greeter.dconf-defaults
  #  '';
  #
  #  # Ensure the profile and settings file are readable by the GDM service
  #  systemd.services.gdm = {
  #    wants = [ "dconf.service" ];  # Ensure dconf is ready before GDM starts
  #    serviceConfig.PermissionsStartOnly = true;
  #    preStart = ''
  #      # Ensure the dconf profile and settings are owned by the GDM user and readable
  #      chown gdm:gdm /etc/gdm/greeter.dconf-defaults
  #      chmod 0644 /etc/gdm/greeter.dconf-defaults
  #      chown gdm:gdm /etc/dconf/profile/gdm
  #      chmod 0644 /etc/dconf/profile/gdm
  #    '';
  #  };
}

