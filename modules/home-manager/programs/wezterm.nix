{
  config,
  pkgs,
  inputs,
  lib,
  system ? builtins.currentSystem,
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
      extraConfig = weztermExtraConfig;
      package = inputs.wezterm.packages.${pkgs.system}.default;
    };
  };
}
