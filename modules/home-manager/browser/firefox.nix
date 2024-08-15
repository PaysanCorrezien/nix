{ pkgs, inputs, ... }:
# NOTE: search firefox codebase https://searchfox.org/mozilla-central/search
#
#TODO: disable all icone of extensions ?
#TODO: ovveride/ change some default shortcut annoying like ctlr n and p,
#TODO: on first connection i still need to import :source ¬/.config/trydactyl/trydactyl.rc
#TODO: customiizing extensions param 
{
  # imports = [ ./glance.nix ];
  programs.firefox = {
    enable = true;
    # policies = policies;
    policies = {
      DisableTelemetry = true;
      DisableFirefoxStudies = true;
      EnableTrackingProtection = {
        Value = true;
        Locked = true;
        Cryptomining = true;
        Fingerprinting = true;
      };
      DisablePocket = true;
      DisableFirefoxAccounts = true;
      DisableAccounts = true;
      DisableFirefoxScreenshots = true;
      # OverrideFirstRunPage = "";
      # OverridePostUpdatePage = "";
      DontCheckDefaultBrowser = true;
      # DisplayBookmarksToolbar = "never"; # alternatives: "always" or "newtab"
      # DisplayMenuBar = "default-off"; # alternatives: "always", "never" or "default-on"
      # SearchBar = "unified"; # alternative: "separate"
      Preferences = {
        "browser.startup.page" = 3; # TEST:
      };

      # ---- EXTENSIONS ----
      # Check about:support for extension/add-on ID strings.
      # Valid strings for installation_mode are "allowed", "blocked",
      # "force_installed" and "normal_installed".
      ExtensionSettings = {
        # ctrl + number for firefox
        "{84601290-bec9-494a-b11c-1baa897a9683}" = {
          install_url =
            "https://addons.mozilla.org/firefox/downloads/file/4192880/ctrl_number_to_switch_tabs-1.0.2.xpi";
          installation_mode = "force_installed";
        };
      };
    };

    profiles.dylan = {
      extensions = with inputs.firefox-addons.packages."x86_64-linux"; [
        privacy-badger
        # auto-accepts cookies, use only with privacy-badger & ublock-origin
        i-dont-care-about-cookies
        # languagetool
        ublock-origin
        darkreader
        tridactyl
        keepassxc-browser
        gnome-shell-integration
        # https://github.com/AbigailBuccaneer/firefox-ctrlnumber missing from list of package
        #TODO: add this to firefox nix

      ];
      settings = {
        "intl.accept_languages" = "en, fr, ja, es";
        # "app.normandy.enabled" = false;
        "app.normandy.first_run" = false;
        "browser.download.panel.shown" = true;
        "identity.fxaccounts.enabled" = false;
        "signon.rememberSignons" = false;
        "browser.startup.homepage_override.mstone" = "ignore";
        "toolkit.legacyUserProfileCustomizations.stylesheets" =
          true; # mandatory to use a userchrome.css
        "startup.homerage_welcome_url" = "";
        "startup.homepage_welcome_url.additional" = "";
        "extensions.autoDisableScopes" =
          0; # automatically enable extensions -> https://nix-community.github.io/home-manager/options.xhtml#opt-programs.firefox.profiles._name_.extensions
        # NOTE: https://github.com/TLATER/dotfiles/blob/b39af91fbd13d338559a05d69f56c5a97f8c905d/home-config/config/graphical-applications/firefox.nix
        # "ui.key.accelKey" = 91; # Re-bind ctrl to super (would interfere with tridactyl otherwise)
        "reader.parse-on-load.force-enabled" =
          false; # Keep the reader button enabled at all times if set to true; tridactyl :reader allow doing it with a shortcut :)
        "ui.key.menuAccessKeyFocuses" =
          false; # Disable alt to focus the menu bar annoying with home row mods for keyboard
        "app.shield.optoutstudies.enabled" = false; # tridactyl want this
        "app.update.auto" = false;
        "browser.contentblocking.category" = "strict";
        "browser.ctrlTab.recentlyUsedOrder" = false;
        "browser.startup.page" =
          "3"; # BUG: need to be set manually for some reason ?
        "browser.newtabpage.pinned" = false;
        "browser.tabs.tabmanager.enabled" =
          false; # Remove the tab about right corner https://support.mozilla.org/mk/questions/1394194
        "services.sync.prefs.sync.browser.newtabpage.pinned" = false;

        "browser.urlbar.placeholderName" = "Search"; # dont work ?
        "browser.urlbar.suggest.topsites" = false;
        "browser.urlbar.suggest.bookmark" = true;
        # "browser.urlbar.matchBuckets" = "suggestion:Infinity,general:5";
        "browser.urlbar.suggest.history" = true;
        "browser.urlbar.suggest.openpage" = true;
        "extensions.pocket.enabled" = false;
        "privacy.trackingprotection.enabled" = true;
        "privacy.trackingprotection.socialtracking.enabled" = true;
        "extensions.getAddons.showPane" = false;
        "browser.shell.checkDefaultBrowser" = false;
        "browser.toolbars.bookmarks.visibility" = "never";
        "extensions.htmlaboutaddons.recommendations.enabled" = false;
        "browser.quitShortcut.disabled" = true;
        "browser.ssb.enabled" = true;
        "browser.laterrun.enabled" = false;
        "browser.bookmarks.restore_default_bookmarks" = false;
        "browser.discovery.enabled" = false;
        "browser.newtabpage.activity-stream.asrouter.userprefs.cfr.addons" =
          false;
        "browser.newtabpage.activity-stream.asrouter.userprefs.cfr.features" =
          false;
        "browser.newtabpage.activity-stream.section.highlights.includePocket" =
          false;
        "browser.newtabpage.activity-stream.feeds.snippets" = false;
        "browser.newtabpage.activity-stream.improvesearch.topSiteSearchShortcuts.havePinned" =
          "";
        "browser.newtabpage.activity-stream.improvesearch.topSiteSearchShortcuts.searchEngines" =
          "";
        "browser.newtabpage.activity-stream.showWeather" = "";
        "browser.newtabpage.activity-stream.showSponsored" = false;
        "browser.newtabpage.activity-stream.showSponsoredTopSites" = false;
        "services.sync.pref.browser.newtabpage.activity-stream.showSponsored" =
          false;
        "services.sync.pref.browser.newtabpage.activity-stream.showSponsoredTopSites" =
          false;
        "services.sync.pref.browser.newtabpage.activity-stream.showSearch" =
          false;
        "browser.protections_panel.infoMessage.seen" = true;
        "datareporting.policy.dataSubmissionEnable" = false;
        "datareporting.policy.dataSubmissionPolicyAcceptedVersion" = 2;

        "extensions.formautofill.creditCards.enabled" = false;

        # printing https://github.com/gvolpe/nix-config/blob/6feb7e4f47e74a8e3befd2efb423d9232f522ccd/home/programs/browsers/firefox.nix
        "print.print_footerleft" = "";
        "print.print_footerright" = "";
        "print.print_headerleft" = "";
        "print.print_headerright" = "";
        # Yubikey
        # "security.webauth.u2f" = true;
        # "security.webauth.webauthn" = true;
        # "security.webauth.webauthn_enable_softtoken" = true;
        # "security.webauth.webauthn_enable_usbtoken" = true;
        # TELEMETRY

        # disable new data submission
        "datareporting.policy.dataSubmissionEnabled" = false;
        # disable Health Reports
        "datareporting.healthreport.uploadEnabled" = false;
        # 0332: disable telemetry
        "toolkit.telemetry.unified" = false;
        "toolkit.telemetry.enabled" = false;
        "toolkit.telemetry.server" = "data:,";
        "toolkit.telemetry.archive.enabled" = false;
        "toolkit.telemetry.newProfilePing.enabled" = false;
        "toolkit.telemetry.shutdownPingSender.enabled" = false;
        "toolkit.telemetry.updatePing.enabled" = false;
        "toolkit.telemetry.bhrPing.enabled" = false;
        "toolkit.telemetry.firstShutdownPing.enabled" = false;
        # disable Telemetry Coverage
        "toolkit.telemetry.coverage.opt-out" = true; # [HIDDEN PREF]
        "toolkit.coverage.opt-out" = true; # [FF64+] [HIDDEN PREF]
        "toolkit.coverage.endpoint.base" = "";
        # disable PingCentre telemetry (used in several System Add-ons) [FF57+]
        "browser.ping-centre.telemetry" = false;
        # disable Firefox Home (Activity Stream) telemetry
        "browser.newtabpage.activity-stream.feeds.telemetry" = false;
        "browser.newtabpage.activity-stream.telemetry" = false;
        "toolkit.telemetry.reportingpolicy.firstRun" = false;
        "toolkit.telemetry.shutdownPingSender.enabledFirstsession" = false;
        "browser.vpn_promo.enabled" = false;
      };
      ## user JS
      #   extraConfig=''
      #   '';
      # for trydactyl this need to be set by default
      # :set newtab about:blank
      userChrome = ''
        tabs {
            counter-reset: tab-counter;
        }

        tab:nth-child(1) .tab-label::before,
        tab:nth-child(2) .tab-label::before,
        tab:nth-child(3) .tab-label::before,
        tab:nth-child(4) .tab-label::before,
        tab:nth-child(5) .tab-label::before,
        tab:nth-child(6) .tab-label::before,
        tab:nth-child(7) .tab-label::before,
        tab:nth-child(8) .tab-label::before {
            background-color: white;
            border-radius: 0.25em;
            border: 1px solid white;
            box-sizing: border-box;
            color: black;
            content: counter(tab-counter) "";
            counter-increment: tab-counter;
            display: block;
            float: left;
            font-size: 0.8em;
            font-weight: bold;
            height: 1.5em;
            line-height: 1;
            margin: 0 0.5em 0 0;
            padding: 0.1em 0.25em 0.25em 0.25em;
            position: relative;
            text-align: center;
            top: 0.35em;
            vertical-align: middle;
            width: 1.4em;
        }

        /* Hide specific icons */
        #PlacesChevron, /* Overflow menu */
        #PanelUI-button, /* Application menu */
        #unified-extensions-button, /* Extensions */
        #tracking-protection-icon-container, /* Tracking protection */
        #pageActionButton, /* Page actions */
        #firefox-view-button, /* FirefoxView */ 
        #star-button-box /* Bookmarks button */ {
            display: none !important;
        }

      '';
      search.engines = {
        "Nix Packages" = {
          urls = [{
            template = "https://search.nixos.org/packages";
            params = [
              {
                name = "type";
                value = "packages";
              }
              {
                name = "query";
                value = "{searchTerms}";
              }
            ];
          }];
          icon =
            "${pkgs.nixos-icons}/share/icons/hicolor/scalable/apps/nix-snowflake.svg";
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
        {
          name = "Nix sites";
          toolbar = true;
          bookmarks = [
            {
              name = "homepage";
              url = "https://nixos.org/";
            }
            {
              name = "wiki";
              tags = [ "wiki" "nix" ];
              url = "https://wiki.nixos.org/";
            }
            {
              name = "home-manager";
              tags = [ "wiki" "nix" ];
              url =
                "https://nix-community.github.io/home-manager/options.xhtml";
            }
          ];
        }
      ];
    };
  };
  # https://nix-community.github.io/home-manager/options.xhtml#opt-programs.firefox.enableGnomeExtensions
  # programs.firefox.enableGnomeExtensions = true;
  # services.gnome.gnome-browser-connector.enable = true; 
  programs.firefox.nativeMessagingHosts =
    [ pkgs.gnome-browser-connector pkgs.tridactyl-native ];
}

# TODO:  create a js and manisfest, zeeper en xpi -> importer dans nix pour permettre l'execution mode plugins
# mkdir ~/.mozilla/extensions/nix_user/
#about:conf xpinstall.signatures.required

