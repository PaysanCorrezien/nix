# home.nix
{ lib, hostName, config, pkgs, inputs, settings, ... }:
let
  isServer = settings.isServer;
in
{
  imports = [
    # Configuration via home.nix
    ./programs/nextloud-cli.nix
    ./graphical/gui.nix
    ./mime-type.nix
    ./gnome/keybinds.nix
    ../chezmoi/chezmoi.nix
    ./browser/firefox.nix
    ./terminals/default.nix
    ./terminals/zsh.nix
    ./gnome/extensions.nix
    ./gnome/settings.nix
    ./programs/nvim.nix
    ./programs/remmina.nix
    ./programs/keepassxc.nix
    ./programs/thunderbird.nix
    ./programs/wezterm.nix
    ./programs/virtualisation.nix
    ./kde/settings.nix
  ];

  home = {
    username = "dylan";
    homeDirectory = "/home/dylan";
    stateVersion = "23.11"; # Please read the comment before changing.
    sessionVariables = {
      EDITOR = "nvim";
      IS_SERVER = toString isServer;
      SOPS_AGE_KEY_FILE = "/var/lib/secrets/${hostName}.txt";
    };
    file = { };
  };

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

  # GUI-related settings
  settings = {
    thunderbird.enable = settings.gui.enable;
    # keepassxc.enable = settings.gui.enable;
    keepassxc.enable = !settings.isServer;
    nextcloudcli.enable = settings.gui.enable;
    # wezterm.enable = settings.gui.enable;
    wezterm.enable = !settings.isServer;
    remmina.enable = settings.gui.enable;
    minimalNvim = settings.isServer;
  };

  # Window manager specific settings
  settings.gnome.extra.enable = lib.mkIf
    (!isServer && settings.windowManager == "gnome")
    true;

  settings.plasma.extra.enable = lib.mkIf
    (!isServer && settings.windowManager == "plasma")
    true;
}
