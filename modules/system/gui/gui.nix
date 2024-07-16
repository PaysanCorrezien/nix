{ config, pkgs, ... }:

{
  imports = [
    ./virtualisation.nix
    ./dev/python.nix
    ./programs/thunderbird.nix
    # ../home-manager/gnome/keybinds.nix
  ];
  # # Enable automatic login for the user.
  # services.displayManager.autoLogin.enable = true;
  # services.displayManager.autoLogin.user = "dylan";
  services.xserver.enable = true;
  services.xserver.desktopManager.gnome.enable = true;
  services.xserver.displayManager.lightdm = { enable = true; };
  # Configure keymap in X11
  services.xserver = {
    xkb.layout = "fr,us";
    xkb.variant = ",altgr-intl";
    #     xkb.options = "grp:alt_shift_toggle"; # Use Alt+Shift to switch between layouts
  };
  # Set X cursor theme globally or it break because of cursor mqybe related to : https://github.com/NixOS/nixpkgs/issues/140505
  # services.xserver.desktopManager.gnome.extraGSettingsOverrides = ''
  #   [org.gnome.desktop.interface]
  #   cursor-theme='Adwaita'
  # '';

  # Workaround for GNOME autologin: https://github.com/NixOS/nixpkgs/issues/103746#issuecomment-945091229
  systemd.services."getty@tty1".enable = false;
  systemd.services."autovt@tty1".enable = false;

  services.espanso.enable = true;
  sound.enable = true;
  hardware.pulseaudio.enable = false;

  # Enable CUPS to print documents.

  # Enable sound with pipewire.
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # If you want to use JACK applications, uncomment this
    #jack.enable = true;

    # use the example session manager (no others are packaged yet so this is enabled by default,
    # no need to redefine it in your config for now)
    #media-session.enable = true;
  };
 
  services.printing.enable = true;

  environment.systemPackages = with pkgs; [
    #  vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
    # tigervnc  
    #TODO: forticlient vpn
    # DEV
    helix
    wezterm

    todoist-electron
    rofi
    # libgcc
    obsidian
    discord
    libnotify

    # ollama
    espanso

    todoist
    flameshot

    # gnome.adwaita-icon-theme
    # xorg.xcursorthemes
    # WORK : 
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
  # TODO: configure it
  services.openssh.enable = true;
  # NOTE: used to rdp to the host, will be needed for wsl
  # Enable rdp for test purpose for now
  # services.xrdp.enable = true;
  # services.xrdp.openFirewall = true;
  # services.xrdp.defaultWindowManager = "startplasma-x11";
  # https://github.com/NixOS/nixpkgs/issues/250533
  # environment.etc = {
  #   "xrdp/sesman.ini".source = "${config.services.xrdp.confDir}/sesman.ini";
  # };
}

