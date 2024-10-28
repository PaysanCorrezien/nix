{
  inputs,
  config,
  pkgs,
  lib,
  ...
}:
{
  # Import the AGS home-manager module
  imports = [ inputs.ags.homeManagerModules.default ];
  options = {
    settings = lib.mkOption {
      type = lib.types.submodule {
        options.astal = lib.mkOption {
          type = lib.types.submodule {
            options.enable = lib.mkEnableOption "Enable custom Astal configuration";
          };
        };
      };
    };
  };

  config = lib.mkIf config.settings.astal.enable {

    # Enable AGS
    programs.ags = {
      enable = true;

      # Essential packages for AGS functionality
      extraPackages = with pkgs; [
        # Only battery is available as a separate package
        inputs.ags.packages.${pkgs.system}.battery

        # Additional tools
        gtk3
        gtk4
        glib
        gjs
        json-glib
        libsoup_3
        webkitgtk

        # Optional but commonly used
        libnotify # notification library

        # If you need JavaScript/TypeScript support
        nodejs
        nodePackages.typescript

        # Additional GTK themes and icons if needed
        gtk-engine-murrine
        gtk_engines
      ];
    };

    # Add AGS CLI tools to your environment
    home.packages = with pkgs; [
      inputs.ags.packages.${pkgs.system}.io # astal cli
      inputs.ags.packages.${pkgs.system}.notifd # notification daemon
    ];
  };
}
