{ pkgs, inputs, ... }:
#TODO: enable extensions without prompt.
#TODO: skip first login message useless
#TODO : theming
#TODO : GPT as installed webapp 
let
  # Define the path for the policies.json file
  policiesJson = pkgs.writeText "policies.json" (builtins.toJSON {
    policies = {
      DisableTelemetry = true;
      DisableFirefoxStudies = true;
      DisableFirefoxAccounts = true;
      DisablePocket = true;
      SearchSuggestEnabled = false;
      DisableSecurityBypass = {
        InvalidCertificate = true;
        SafeBrowsing = true;
      };
      DontCheckDefaultBrowser = true;
      PasswordManagerEnabled = false;
      OfferToSaveLoginsDefault = false;
      FirefoxHome = {
        Search = true;
        TopSites = false;
        SponsoredTopSites = false;
        Highlights = false;
        Pocket = false;
        SponsoredPocket = false;
        Snippets = false;
        Locked = true;
      };
      FirefoxSuggest = {
        WebSuggestions = false;
        SponsoredSuggestions = false;
        ImproveSuggest = false;
        Locked = true;
      };
      Permissions = {
        Camera = { BlockNewRequests = true; };
        Microphone = { BlockNewRequests = true; };
        Location = {
          BlockNewRequests = true;
          Locked = true;
        };
      };
      Homepage = {
        URL = "about:profiles | about:config | about:policies | about:debugging#/runtime/this-firefox";
      };
      ExtensionSettings = {
        "*".installation_mode = "allowed"; # Allow all addons except the ones explicitly blocked
        
        # uBlock Origin:
        "uBlock0@raymondhill.net" = {
          installation_mode = "force_installed";
        };
        # SponsorBlock:
        "{sponsorblock@ajay.app}" = {
          installation_mode = "force_installed";
        };
        # Dark Reader:
        "addon@darkreader.org" = {
          installation_mode = "force_installed";
        };
        # Tridactyl:
        "tridactyl.vim@cmcaine.co.uk" = {
          installation_mode = "force_installed";
        };
        # YouTube Shorts Block:
        "{youtube-shorts-block@youtube-shorts-block.com}" = {
          installation_mode = "force_installed";
        };
        # Firefox Color:
        "{firefox-color@mozilla.com}" = {
          installation_mode = "force_installed";
        };
        # KeePassXC Browser:
        "keepassxc-browser@keepassxc.org" = {
          installation_mode = "force_installed";
        };
        # GNOME Shell Integration:
        "chrome-gnome-shell@gnome.org" = {
          installation_mode = "force_installed";
        };
        # firefox-ctrlnumber:
        "{abigailbuccaneer-firefox-ctrlnumber}" = {
          install_url = "https://github.com/AbigailBuccaneer/firefox-ctrlnumber/releases/download/v1.0/firefox-ctrlnumber.xpi";
          installation_mode = "force_installed";
        };
      };
    };
  });
in
{
  programs.firefox = {
    enable = true;
    package = pkgs.firefox-esr.override {
      extraPolicies = policiesJson;
    };
    profiles.dylan = {
      extensions = with inputs.firefox-addons.packages."x86_64-linux"; [
        ublock-origin
        sponsorblock
        darkreader
        tridactyl
        youtube-shorts-block
        firefox-color
        keepassxc-browser
        gnome-shell-integration
      ];
      settings = {
        "dom.security.https_only_mode" = true;
        "browser.download.panel.shown" = true;
        "identity.fxaccounts.enabled" = false;
        "signon.rememberSignons" = false;
        "browser.startup.homepage_override.mstone" = "ignore";
        "startup.homepage_welcome_url" = "";
        "startup.homepage_welcome_url.additional" = "";
        "browser.startup.page" = 0;
      };
      # for tridactyl this need to be set by default
      # :set newtab about:blank
      userChrome = ''
        /* some css */
      '';
      search.engines = {
        "Nix Packages" = {
          urls = [{
            template = "https://search.nixos.org/packages";
            params = [
              { name = "type"; value = "packages"; }
              { name = "query"; value = "{searchTerms}"; }
            ];
          }];
          icon = "${pkgs.nixos-icons}/share/icons/hicolor/scalable/apps/nix-snowflake.svg";
          definedAliases = [ "@np" ];
        };
      };
      search.force = true;
      bookmarks = [
        {
          name = "Wikipedia";
          tags = [ "wiki" ];
          keyword = "wiki";
          url = "https://en.wikipedia.org/wiki/Special:Search?search=%s&go=Go";
        }
      ];
    };
  };
}

