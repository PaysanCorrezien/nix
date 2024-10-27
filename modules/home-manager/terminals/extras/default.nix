{
  settings,
  lib,
  config,
  pkgs,
  ...
}:
let
  cfg = settings.terminal.extras;
  rustscanFullScript = pkgs.writeShellScriptBin "rustscanfull" ''
    #!/usr/bin/env bash
    if [ $# -eq 0 ]; then
      echo "Usage: rustscanfull <IP address or CIDR>"
      exit 1
    fi

    target="$1"
    timestamp=$(date +%Y%m%d_%H%M%S)
    sanitized_target=$(echo "$target" | tr '/' '_')
    output_file="$HOME/''${sanitized_target}_$timestamp.txt"

    echo "Scanning $target. Output will be written to $output_file"

    rustscan -a "$target" --ulimit 10000 -- -sV -sC -Pn -oN "$output_file"

    echo "Scan complete. Results written to $output_file"
  '';
in
{
  imports = [
    ./btop.nix
    ./rust.nix
    ./lazygit.nix
    ./fonts.nix
    ./cava.nix
    ./ytfzf.nix
    ./aichat.nix
    ./nushell.nix
    ./atuin.nix
    ./thefuck.nix
    ./carapace.nix
  ];
  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
      imagemagick
      rustscan
      rustscanFullScript
      bluetuith # bluetouth TUI
      asn # OSINT command line tool for investigating network data
      gping # Ping, but with a graph
      systemctl-tui # systemctl manager tui
      monolith # download webpage as HTML
    ];
    programs.bash.shellAliases = {
      rustscanfull = "rustscanfull";
    };
    programs.zsh.shellAliases = {
      rustscanfull = "rustscanfull";
    };
  };
}
