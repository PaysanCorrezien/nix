# hosts/lenovo.nix
{ inputs, config, pkgs, lib, ... }: {
  settings.isServer = false;
  settings.virtualisation.enable = true;

  imports = [
    ../modules/system/gui/gui.nix
    ../modules/system/terminal/terminal.nix
    ../modules/common.nix
    ../dynamic-grub.nix
    ../modules/sops.nix
  ];

  networking.hostName = "lenovo";

  # boot.loader.grub.device = "/dev/sda"; # Adjust as needed

  # Other host-specific settings

  # TODO: move to gnome.nix
  # Enable the GNOME Desktop Environment.

  environment.systemPackages = with pkgs; [
    acpi # battery util
    adwaita-icon-theme
  ];
}

