{
  config,
  lib,
  pkgs,
  ...
}:
let
  niriPortalsConf = ''
    [preferred]
    default=gnome;gtk;
    org.freedesktop.impl.portal.Access=gtk;
    org.freedesktop.impl.portal.Notification=gtk;
    org.freedesktop.impl.portal.Secret=gnome-keyring;
    org.freedesktop.impl.portal.FileChooser=gtk;
  '';
in
{
  config = lib.mkIf (config.settings.windowManager == "niri") {
    settings.displayServer = lib.mkDefault "wayland";
    settings.stylix.enable = lib.mkForce false;
    programs.niri.enable = true;

    environment.sessionVariables = {
      XDG_CURRENT_DESKTOP = "niri";
      XDG_SESSION_DESKTOP = "niri";
    };

    xdg.portal = {
      enable = true;
      extraPortals = [
        pkgs.xdg-desktop-portal-gtk
        pkgs.xdg-desktop-portal-gnome
      ];
    };

    environment.etc."xdg-desktop-portal/niri-portals.conf".text = niriPortalsConf;

    programs.dconf.enable = true;
    services.gnome.gnome-keyring.enable = true;
    security.polkit.enable = true;

    systemd.user.services.polkit-gnome-authentication-agent-1 = {
      description = "Polkit GNOME Authentication Agent";
      wantedBy = [ "graphical-session.target" ];
      partOf = [ "graphical-session.target" ];
      after = [ "graphical-session.target" ];
      serviceConfig = {
        ExecStart = "${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1";
        Restart = "on-failure";
      };
    };

    systemd.user.services.mako = {
      description = "Mako notification daemon";
      wantedBy = [ "graphical-session.target" ];
      partOf = [ "graphical-session.target" ];
      after = [ "graphical-session.target" ];
      serviceConfig = {
        ExecStart = "${pkgs.mako}/bin/mako";
        Restart = "on-failure";
      };
    };

    systemd.user.services.xwayland-satellite = {
      description = "Xwayland Satellite (X11 support for Wayland)";
      wantedBy = [ "graphical-session.target" ];
      partOf = [ "graphical-session.target" ];
      after = [ "graphical-session.target" ];
      serviceConfig = {
        ExecStart = "${pkgs.xwayland-satellite}/bin/xwayland-satellite";
        Restart = "on-failure";
      };
    };

    environment.systemPackages = with pkgs; [
      gnome-keyring
      mako
      polkit_gnome
      xdg-desktop-portal-gtk
      xdg-desktop-portal-gnome
      xwayland-satellite
    ];
  };
}
