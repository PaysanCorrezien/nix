{ config, input, ... }:

{
  programs.wezterm.enable = true;
  programs.wezterm.enabbleBashIntegration = true;
  programs.wezterm.enableZshIntegration = true;
}
