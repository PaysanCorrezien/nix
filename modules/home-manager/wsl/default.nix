# WSL-specific home-manager additions
# Note: Core configs (zsh, nvim, yazi) are now in the main modules with WSL conditionals
{
  lib,
  config,
  pkgs,
  settings,
  ...
}:

{
  imports = [
    ./tmux.nix
    ./onedrive.nix
    ./code.nix
  ];

  # Core terminal tools (WSL-specific setup)
  programs.bat = {
    enable = true;
    config = { style = "auto,header-filesize"; };
    extraPackages = with pkgs.bat-extras; [
      batdiff
      batgrep
      batman
    ];
  };

  programs.ripgrep = {
    enable = true;
    arguments = [
      "--max-columns=150"
      "--max-columns-preview"
      "--glob=!.git/*"
      "--smart-case"
    ];
  };

  programs.fzf = {
    enable = true;
    enableZshIntegration = true;
  };

  programs.carapace = {
    enable = true;
    enableZshIntegration = true;
  };

  programs.nh = {
    enable = true;
    clean = {
      enable = true;
      extraArgs = "--keep-since 7d --keep 10";
    };
    flake = "${settings.paths.homeDirectory}/repo/nix";
  };

  programs.starship = {
    enable = true;
    enableZshIntegration = true;
    settings = {
      palette = "catppuccin_mocha";

      palettes.catppuccin_mocha = {
        rosewater = "#f5e0dc";
        flamingo = "#f2cdcd";
        pink = "#f5c2e7";
        mauve = "#cba6f7";
        red = "#f38ba8";
        maroon = "#eba0ac";
        peach = "#fab387";
        yellow = "#f9e2af";
        green = "#a6e3a1";
        teal = "#94e2d5";
        sky = "#89dceb";
        sapphire = "#74c7ec";
        blue = "#89b4fa";
        lavender = "#b4befe";
        text = "#cdd6f4";
        subtext1 = "#bac2de";
        subtext0 = "#a6adc8";
        overlay2 = "#9399b2";
        overlay1 = "#7f849c";
        overlay0 = "#6c7086";
        surface2 = "#585b70";
        surface1 = "#45475a";
        surface0 = "#313244";
        base = "#1e1e2e";
        mantle = "#181825";
        crust = "#11111b";
      };

      character = {
        success_symbol = "[➜](bold green)";
        error_symbol = "[✗](bold red)";
      };

      aws.disabled = true;
      gcloud.disabled = true;
      kubernetes.disabled = true;

      directory = {
        truncation_length = 5;
        truncate_to_repo = true;
      };

      git_branch = {
        symbol = "🌱 ";
        truncation_length = 20;
        truncation_symbol = "...";
      };

      git_status = {
        conflicted = "🏳";
        ahead = "🏎💨";
        behind = "😰";
        diverged = "😵";
        up_to_date = "✓";
        untracked = "🤷";
        stashed = "📦";
        modified = "📝";
        staged = "[++\\($count\\)](green)";
        renamed = "👅";
        deleted = "🗑";
      };

      nix_shell = {
        symbol = "❄️ ";
        format = "via [$symbol$state( \($name\))]($style) ";
      };
    };
  };

  # WSL-specific packages
  home.packages = with pkgs; [
    bat
    bc
    btop
    carapace
    fd
    ffmpeg
    fzf
    gcc
    gh
    jq
    just
    lazydocker
    lazygit
    lsd
    nil
    pandoc
    poppler-utils
    ripgrep
    ripgrep-all
    rustscan
    sshfs
    starship
    stylua
    unzip
    xclip
    yq
    zip
    zoxide
  ];

  # WSL-friendly xclip wrapper to use Windows clipboard
  home.file.".local/bin/xclip" = {
    executable = true;
    text = ''
      #!/usr/bin/env bash
      set -euo pipefail

      mode="copy"
      for arg in "$@"; do
        if [ "$arg" = "-o" ]; then
          mode="paste"
          break
        fi
      done

      # Prefer native X/Wayland if available
      if [ -n "''${DISPLAY:-}" ] || [ -n "''${WAYLAND_DISPLAY:-}" ]; then
        exec ${pkgs.xclip}/bin/xclip "$@"
      fi

      if [ -n "''${WSL_DISTRO_NAME:-}" ] && [ -x /mnt/c/Windows/System32/clip.exe ]; then
        if [ "$mode" = "copy" ]; then
          cat | /mnt/c/Windows/System32/clip.exe
        else
          powershell.exe -NoProfile -Command 'Get-Clipboard -Raw' | tr -d '\r'
        fi
        exit 0
      fi

      echo "xclip: no display and no Windows clipboard available" >&2
      exit 1
    '';
  };
}
