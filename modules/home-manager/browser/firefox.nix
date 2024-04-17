 { pkgs, inputs, ... }:
#TODO: enable extemsions without prompt.
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
	# https://github.com/AbigailBuccaneer/firefox-ctrlnumber missing from list of package
	#TODO: add this to firefox nix

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
      # for trydactyl this need to be set by default
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

