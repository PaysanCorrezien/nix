# Unified home.nix (works for desktop, server, and WSL)
{
  lib,
  hostName,
  config,
  pkgs,
  inputs,
  settings,
  ...
}:
let
  isServer = settings.isServer;
  isWSL = settings.isWSL or false;
  isDesktop = !isServer && !isWSL;
in
{
  imports = [
    # Central settings options definition
    ./settings-options.nix

    # Core modules (all environments)
    ./terminals/default.nix
    ./terminals/zsh.nix
    ./programs/nvim.nix
    ./mime-type.nix

    # WSL-specific extras
  ] ++ lib.optionals isWSL [
    ./wsl/default.nix
  ] ++ lib.optionals isDesktop [
    # Desktop-only imports
    ./programs/nextloud-cli.nix
    ./graphical/gui.nix
    ./gnome/keybinds.nix
    ../chezmoi/chezmoi.nix
    ./browser/firefox.nix
    ./gnome/extensions.nix
    ./gnome/settings.nix
    ./programs/remmina.nix
    ./programs/keepassxc.nix
    ./programs/thunderbird.nix
    # ./programs/wezterm.nix
    ./programs/ghostty.nix
    ./programs/virtualisation.nix
    ./hyprland/settings.nix
    ./hyprland/waybar.nix
    ./hyprland/wlogout.nix
    ./niri/settings.nix
    ./stylix/default.nix
    ./programs/astal.nix
    ./programs/rofi.nix
  ];

  home = {
    username = settings.username;
    homeDirectory = settings.paths.homeDirectory;
    stateVersion = "24.11";
    sessionVariables = {
      EDITOR = "nvim";
      IS_SERVER = toString isServer;
    } // lib.optionalAttrs (!isWSL) {
      SOPS_AGE_KEY_FILE = settings.paths.ageKeyFile;
    };
    file = { };
  };

  programs.home-manager.enable = true;
}
