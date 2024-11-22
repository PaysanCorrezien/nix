{
  config,
  pkgs,
  inputs,
  lib,
  system ? builtins.currentSystem, # Provide a default value for system
  ...
}:

let
  weztermExtraConfig = ''
    -- Add your config directory to Lua's package path
    package.path = package.path .. ";${config.home.homeDirectory}/repo/config.wezterm/?.lua"

    -- Import your config
    return require("init")  -- or whatever you named your entry file

  '';

in
# nixpkgs-24-05 = fetchTarball {
#   url = "https://github.com/NixOS/nixpkgs/archive/957d95fc8b9bf1eb60d43f8d2eba352b71bbf2be.tar.gz";
#   sha256 = "sha256:0jkxg1absqsdd1qq4jy70ccx4hia3ix891a59as95wacnsirffsk";
# };
#
# wezterm-24-05 = (import nixpkgs-24-05 { }).wezterm;
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
      # package = wezterm-24-05;
      extraConfig = weztermExtraConfig;
      package = inputs.wezterm.packages.${pkgs.system}.default; # Use pkgs.system instead
    };
  };
}
