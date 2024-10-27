{
  inputs,
  pkgs,
  lib,
  ...
}:
{
  # Import the AGS home-manager module
  imports = [ inputs.ags.homeManagerModules.default ];

  # Enable AGS
  programs.ags = {
    enable = true;

    # Essential packages for AGS functionality
    extraPackages = with pkgs; [
      # Only battery is available as a separate package
      inputs.ags.packages.${pkgs.system}.battery

      # System utilities
      brightnessctl
      light
      pamixer
      pulseaudio
      networkmanager
      playerctl

      # Additional tools
      gtk3
      gtk4
      glib
      gjs
      json-glib
      libsoup_3
      webkitgtk

      # Development tools
      fzf
      ripgrep
      fd

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
}
