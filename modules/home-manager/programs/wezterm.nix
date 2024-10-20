{ config, pkgs, lib, ... }:

let
  weztermExtraConfig = ''
    require "events.update-status"
    require "events.format-tab-title"
    return require("utils.config"):new():add("config"):add "mappings"
  '';

  nixpkgs-24-05 = fetchTarball {
    url = "https://github.com/NixOS/nixpkgs/archive/957d95fc8b9bf1eb60d43f8d2eba352b71bbf2be.tar.gz";
    sha256 = "sha256:0jkxg1absqsdd1qq4jy70ccx4hia3ix891a59as95wacnsirffsk";
  };

  wezterm-24-05 = (import nixpkgs-24-05 {}).wezterm;
in
{
  options.settings = lib.mkOption {
    type = lib.types.submodule {
      options.wezterm = lib.mkOption {
        type = lib.types.submodule {
          options.enable = lib.mkEnableOption "Enable custom Wezterm configuration";
        };
      };
    };
  };

  config = lib.mkIf config.settings.wezterm.enable {
    programs.wezterm = {
      enable = true;
      enableBashIntegration = true;
      enableZshIntegration = true;
      package = wezterm-24-05;
      extraConfig = weztermExtraConfig;
    };
  };
}
