{
  config,
  pkgs,
  inputs,
  ...
}:
let
  # Create a wrapper script for yazi that handles the WezTerm start command
  yaziWrapper = pkgs.writeShellScriptBin "yazi-terminal" ''
    exec start -- yazi "$@"
  '';
in
{
  environment.systemPackages = with pkgs; [
    pinentry-tty
    starship
    tldr
    xclip
    openssl
    git
    fzf
    zoxide
    fd
    yazi
    yaziWrapper # Add our wrapper
    lsd
    unzip
    bc # for math calculations on shell
    zip
    ripgrep
    wget
    #NOTE: this makes wezterm my default env for running commands
    # use a trick by symlinking wezterm to xdg-terminal-exec
    (pkgs.symlinkJoin {
      name = "wezterm-xdg-terminal";
      paths = [ wezterm ];
      postBuild = ''
        mkdir -p $out/bin
        echo '#!/bin/sh' > $out/bin/xdg-terminal-exec
        echo 'exec ${wezterm}/bin/wezterm start -- "$@"' >> $out/bin/xdg-terminal-exec
        chmod +x $out/bin/xdg-terminal-exec
      '';
    })
  ];
}
