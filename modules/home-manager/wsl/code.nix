# Development tools configuration
# Includes Python/uv, Node.js/npm, and Nix development utilities
{
  lib,
  config,
  pkgs,
  ...
}:

{
  # Development packages
  home.packages = with pkgs; [
    # Python and uv
    python3
    python3Packages.pip
    uv

    # Node.js and npm
    nodejs_latest

    # Nix development tools
    nixpkgs-fmt  # Formatter for Nix code
    nix-doc       # Documentation tool for Nix
    nix-tree      # Visualize Nix dependency trees

    # Markdown tools
    markdown-oxide

    # Development tools - NOT available in current nixpkgs (2024-12-19)
    # These packages were added to nixpkgs after 2026-01-11
    # To use them: run `nix flake update nixpkgs` (may require fixing other breaking changes)
    # codex
    # cursor-cli
    # supabase-cli
  ];

  # Configure npm to use writable directory instead of Nix store
  home.file.".npmrc".text = ''
    prefix=${config.home.homeDirectory}/.npm-global
  '';

  # Configure direnv
  programs.direnv = {
    enable = true;
    enableZshIntegration = true;
    nix-direnv.enable = true;
  };

  # Environment variables for npm
  home.sessionVariables = {
    NPM_CONFIG_PREFIX = "$HOME/.npm-global";
  };

  # Add npm global bin to PATH
  home.sessionPath = [ "$HOME/.npm-global/bin" ];

  # Create npm global directory structure
  # Note: Using builtins.replaceStrings to ensure Unix line endings in activation script
  home.activation.createNpmGlobalDir = lib.hm.dag.entryAfter [ "writeBoundary" ] (
    builtins.replaceStrings [ "\r\n" "\r" ] [ "\n" "\n" ] ''
      mkdir -p "$HOME/.npm-global/bin"
    ''
  );
}

