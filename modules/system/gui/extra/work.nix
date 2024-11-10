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
  # Helper function to create web app derivations
  mkWebAppBase =
    browser: args:
    (pkgs.stdenvNoCC.mkDerivation (
      args
      // {
        pname = "${browser.pname}-app-${args.appName}";
        version = "1.0.0";
        buildInputs = [ browser ];
        nativeBuildInputs = [
          pkgs.makeBinaryWrapper
          pkgs.copyDesktopItems
        ];
        dontUnpack = true;
        dontConfigure = true;
        dontBuild = true;

        installPhase =
          let
            # Browser-specific flags defined within the let block
            browserFlags =
              if browser.pname == "microsoft-edge" then
                {
                  appFlag = "--app";
                  classFlag = "--class";
                  extraFlags = [ ];
                }
              else if browser.pname == "chromium" then
                {
                  appFlag = "--app";
                  classFlag = "--class";
                  extraFlags = [
                    "--enable-features=UseOzonePlatform,WebRTCPipeWireCapturer,WebUIDarkMode"
                    "--ozone-platform-hint=auto"
                    "--disable-sync-preferences"
                  ];
                }
              else
                {
                  appFlag = "--app";
                  classFlag = "--class";
                  extraFlags = [ ];
                };

            # Profile directory flag if enabled
            profileFlag =
              if args.separateProfile then
                ''--add-flags "--user-data-dir=\$XDG_CONFIG_HOME/${browser.pname}-${args.appName}"''
              else
                "";
          in
          ''
            runHook preInstall

            makeWrapper ${lib.getExe browser} $out/bin/${args.appName} \
              ${lib.concatStringsSep " " (map (flag: "--add-flags \"${flag}\"") browserFlags.extraFlags)} \
              --add-flags "${browserFlags.appFlag}=${args.url}" \
              --add-flags "${browserFlags.classFlag}=${args.windowClass or args.appName}" \
              ${profileFlag}

            runHook postInstall
          '';

        desktopItems = [
          (pkgs.makeDesktopItem {
            name = args.appName;
            exec = args.appName;
            icon = args.icon;
            desktopName = args.name;
            genericName = args.description or args.name;
            categories =
              [ "Network" ]
              ++ (map (cat: if (lib.hasPrefix "X-" cat) then cat else "X-${cat}") (args.extraCategories or [ ]));
            startupWMClass = args.windowClass or args.appName;
            terminal = false;
            type = "Application";
          })
        ];
      }
    ));

  # Higher-level wrapper maintaining your preferred API
  mkWebApp =
    {
      name,
      desktopId,
      url,
      icon,
      description ? "",
      extraCategories ? [ ],
      browser ? pkgs.microsoft-edge, # Default browser, can be overridden
      sandboxProfile ? true, # New option, defaults to true for backward compatibility
    }:
    let
      windowClass = lib.strings.toLower (builtins.replaceStrings [ " " ] [ "-" ] name);
    in
    mkWebAppBase browser {
      appName = desktopId;
      inherit
        name
        url
        icon
        description
        extraCategories
        windowClass

        ;
      separateProfile = sandboxProfile;
    };

  # Web apps definitions remain the same
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
    sandboxProfile = false;
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
    sandboxProfile = false;
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
    sandboxProfile = false;
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
    sandboxProfile = false;
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
    sandboxProfile = false;
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
    sandboxProfile = false;
  };

in
{
  config = lib.mkIf cfg.work {
    environment.systemPackages = with pkgs; [
      microsoft-edge
      linphone
      openfortivpn
      # teamviewer
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
