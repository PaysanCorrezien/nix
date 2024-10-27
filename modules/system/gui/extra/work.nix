# TODO: prepare an automount script for drive 
# configure powershell modules ?
# TODO: nix doest provite any settings for it . and i have psfzf as mandatory dep
# Helper function to create web app desktop entries
{
  config,
  pkgs,
  lib,
  ...
}:

let
  cfg = config.settings;

  # Helper function to create web app desktop entries
  mkWebApp =
    {
      name,
      desktopId,
      url,
      icon,
      description ? "",
      extraCategories ? [ ],
    }:
    let
      windowClass = lib.strings.toLower (builtins.replaceStrings [ " " ] [ "-" ] name);
    in
    pkgs.makeDesktopItem {
      name = desktopId;
      desktopName = name;
      genericName = description;
      icon = icon;
      exec = "${pkgs.microsoft-edge}/bin/microsoft-edge-stable --app=\"${url}\" --class=\"${windowClass}\"";
      categories = [
        "Network"
      ] ++ (map (cat: if (lib.hasPrefix "X-" cat) then cat else "X-${cat}") extraCategories);
      terminal = false;
      type = "Application";
    };

  # Web apps definitions
  youtubeWebApp = mkWebApp {
    name = "YouTube";
    desktopId = "youtube-webapp";
    url = "https://youtube.com";
    icon = ./../../../../assets/youtube-icon.svg;
    description = "YouTube Video Platform";
    extraCategories = [
      "X-AudioVideo"
      "X-Entertainment"
    ];
  };

  claudeWebApp = mkWebApp {
    name = "Claude AI";
    desktopId = "claude-ai";
    url = "https://claude.ai/new";
    icon = ./../../../../assets/claude-icon.svg;
    description = "Claude AI Assistant";
    extraCategories = [
      "X-Development"
      "X-AI"
    ];
  };

  githubWebApp = mkWebApp {
    name = "GitHub";
    desktopId = "github-webapp";
    url = "https://github.com";
    icon = ./../../../../assets/github-icon.svg;
    description = "GitHub Web Interface";
    extraCategories = [
      "X-Development"
      "X-Collaboration"
    ];
  };

  teamsWebApp = mkWebApp {
    name = "Microsoft Teams";
    desktopId = "ms-teams-webapp";
    url = "https://teams.microsoft.com";
    icon = ./../../../../assets/microsoft-teams.svg;
    description = "Microsoft Teams";
    extraCategories = [
      "X-InstantMessaging"
      "X-Office"
    ];
  };

  nixosDiscourseWebApp = mkWebApp {
    name = "NixOS Discourse";
    desktopId = "nixos-discourse";
    url = "https://discourse.nixos.org";
    icon = ./../../../../assets/nixos.svg;
    description = "NixOS Community Forums";
    extraCategories = [
      "X-Development"
      "X-Community"
    ];
  };

  chatGPTWebApp = mkWebApp {
    name = "ChatGPT";
    desktopId = "chatgpt";
    url = "https://chat.openai.com";
    icon = ./../../../../assets/openai-icon.svg;
    description = "ChatGPT AI Assistant";
    extraCategories = [
      "X-Development"
      "X-AI"
    ];
  };

in
{
  config = lib.mkIf cfg.work {
    environment.systemPackages = with pkgs; [
      microsoft-edge
      linphone
      openfortivpn
      wireshark
      teamviewer
      vscode-extensions.ms-vscode.powershell

      # Web apps
      youtubeWebApp
      claudeWebApp
      githubWebApp
      teamsWebApp
      nixosDiscourseWebApp
      chatGPTWebApp
    ];

  };
}
