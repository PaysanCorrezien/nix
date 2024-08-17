{ config, pkgs, lib, ... }:

#TODO: migrate all my wezterm config to nix
# find a way to import plugins ? 
# and create config recursively from a wezterm subfolder or external github repo?
let
  weztermExtraConfig = ''
    require "events.update-status"
    require "events.format-tab-title"
    return require("utils.config"):new():add("config"):add "mappings"
  '';

in {
  options = {
    settings = lib.mkOption {
      type = lib.types.submodule {
        options.wezterm = lib.mkOption {
          type = lib.types.submodule {
            options.enable =
              lib.mkEnableOption "Enable custom Wezterm configuration";
          };
        };
      };
    };
  };

  config = lib.mkIf config.settings.wezterm.enable {
    programs.wezterm = {
      enable = true;
      enableBashIntegration = true;
      enableZshIntegration = true;
      package = pkgs.wezterm;
      extraConfig = weztermExtraConfig;
    };
  };
}
