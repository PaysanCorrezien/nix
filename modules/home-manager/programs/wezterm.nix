{ pkgs, config, input, ... }:

{
  programs.wezterm.enable = true;
  programs.wezterm.enableBashIntegration = true;
  programs.wezterm.enableZshIntegration = true;
  programs.wezterm.package = pkgs.wezterm;
  programs.wezterm.extraConfig = ''
        require "events.update-status"
    require "events.format-tab-title"

    return require("utils.config"):new():add("config"):add "mappings"
  '';
}
