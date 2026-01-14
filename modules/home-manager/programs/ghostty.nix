{
  config,
  pkgs,
  lib,
  ...
}:
{
  programs.ghostty = {
    enable = true;
    enableZshIntegration = true;
    enableBashIntegration = true;
  };
}
