{
  lib,
  config,
  pkgs,
  ...
}:
{
  # Only install our portal
  services.dbus.packages = [ pkgs.xdg-desktop-portal-termfilechooser ];

  environment.etc = {
    "xdg-desktop-portal/portals/gtk.portal" = {
      text = ''
        [portal]
        DBusName=org.freedesktop.impl.portal.desktop.gtk
        Interfaces=org.freedesktop.impl.portal.Settings
        UseIn=gtk
      '';
    };
    "xdg-desktop-portal/portals/gnome.portal" = {
      text = ''
        [portal]
        DBusName=org.freedesktop.impl.portal.desktop.gnome
        Interfaces=org.freedesktop.impl.portal.Settings
        UseIn=gnome
      '';
    };
    "xdg-desktop-portal/portals.conf" = {
      text = ''
        [preferred]
        default=termfilechooser
        org.freedesktop.impl.portal.FileChooser=termfilechooser
        [removals]
        org.freedesktop.impl.portal.FileChooser=gtk;gnome
        [backends]
        org.freedesktop.impl.portal.FileChooser=termfilechooser
      '';
    };
    "xdg-desktop-portal/portals/termfilechooser.portal" = {
      text = ''
        [portal]
        DBusName=org.freedesktop.impl.portal.desktop.termfilechooser
        Interfaces=org.freedesktop.impl.portal.FileChooser
        UseIn=*
        Priority=999
        Default=true
      '';
    };
  };
  #
  # environment.gnome.excludePackages = with pkgs; [
  #   xdg-desktop-portal-gtk
  #   xdg-desktop-portal-gnome
  #   xdg-desktop-portal
  # ];
  #
  # systemd.user.services = {
  #   "xdg-desktop-portal" = {
  #     serviceConfig = {
  #       Type = "dbus";
  #       BusName = "org.freedesktop.portal.Desktop";
  #       ExecStart = [
  #         "" # Clear any existing ExecStart
  #         "${pkgs.xdg-desktop-portal}/libexec/xdg-desktop-portal"
  #       ];
  #       Environment = [
  #         "XDG_DESKTOP_PORTAL_DIR=/etc/xdg-desktop-portal/portals"
  #         "XDG_CURRENT_DESKTOP=termfilechooser"
  #       ];
  #     };
  #     path = [ pkgs.xdg-desktop-portal-termfilechooser ];
  #   };
  #   "xdg-document-portal" = {
  #     enable = false;
  #   };
  #   "xdg-desktop-portal-gtk" = {
  #     enable = false;
  #   };
  #   "xdg-desktop-portal-gnome" = {
  #     enable = false;
  #   };
  # };
}
