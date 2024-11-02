{
  config,
  pkgs,
  lib,
  settings,
  ...
}:

let

  cfg = settings.thunderbird;
  thunderbirdSecretsPath = "/run/secrets";

  # Function to read a secret file and return its content or an empty string
  readSecretFile =
    name:
    let
      path = "${thunderbirdSecretsPath}/${name}";
    in
    if builtins.pathExists path then builtins.readFile path else "";

  # Function to check if all required secrets for an account exist
  accountSecretsExist =
    prefix: (readSecretFile "${prefix}/name") != "" && (readSecretFile "${prefix}/email") != "";

  settingsPath = "${config.home.homeDirectory}/.thunderbird/default/extension-settings.json";

  # Read existing settings if file exists
  existingSettings =
    if builtins.pathExists settingsPath then
      builtins.fromJSON (builtins.readFile settingsPath)
    else
      {
        version = 3;
        commands = { };
        prefs = { };
        default_search = { };
      };

  # Our new settings to merge
  newSettings = {
    commands = {
      goto.precedenceList = [
        {
          id = "quickmove@mozilla.kewis.ch";
          installDate = 1730496882367;
          value.shortcut = "Ctrl+Shift+G";
          enabled = true;
        }
      ];
      copy.precedenceList = [
        {
          id = "quickmove@mozilla.kewis.ch";
          installDate = 1730496882367;
          value.shortcut = "Ctrl+Shift+C";
          enabled = true;
        }
      ];
      move.precedenceList = [
        {
          id = "quickmove@mozilla.kewis.ch";
          installDate = 1730496882367;
          value.shortcut = "Ctrl+Shift+N";
          enabled = true;
        }
      ];
    };
  };

  # Debug existing settings
  _ = builtins.trace "Existing settings: ${builtins.toJSON existingSettings}" null;

  # Merge settings
  mergedSettings = lib.recursiveUpdate existingSettings newSettings;

in
{
  options = {
    settings = lib.mkOption {
      type = lib.types.submodule {
        options.thunderbird = lib.mkOption {
          type = lib.types.submodule {
            options.enable = lib.mkEnableOption "Enable custom Thunderbird configuration";
          };
        };
      };
    };
  };

  config = lib.mkIf config.settings.thunderbird.enable {

    home.file.".thunderbird/default/extension-settings.json".text = builtins.toJSON mergedSettings;

    programs.thunderbird = {
      enable = true;
      package = pkgs.thunderbird.override {
        extraPolicies = {
          ExtensionSettings = {
            "*".installation_mode = "blocked";
            "owl@beonex.com" = {
              install_url = "https://addons.thunderbird.net/thunderbird/downloads/latest/owl-for-exchange/latest.xpi";
              installation_mode = "force_installed";
            };
            "{a62ef8ec-5fdc-40c2-873c-223b8a6925cc}" = {
              install_url = "https://addons.thunderbird.net/thunderbird/downloads/latest/provider-for-google-calendar/latest.xpi";
              installation_mode = "force_installed";
            };
            # Added Quick Folder Move
            "quickmove@mozilla.kewis.ch" = {
              install_url = "https://addons.thunderbird.net/thunderbird/downloads/latest/quick-folder-move/addon-12018-latest.xpi";
              installation_mode = "force_installed";
            };
            # Added ThirdStats
            "thirdstats@devmount.de" = {
              install_url = "https://addons.thunderbird.net/thunderbird/downloads/latest/thirdstats/addon-987909-latest.xpi";
              installation_mode = "force_installed";
            };
            "tbkeys@addons.thunderbird.net" = {
              install_url = "https://github.com/wshanks/tbkeys/releases/latest/download/tbkeys.xpi";
              installation_mode = "force_installed";
            };
            #
            "{f6d05f0c-39a8-5c4d-96dd-4852202a8244}" = {
              install_url = "https://raw.githubusercontent.com/catppuccin/thunderbird/main/themes/mocha/mocha-blue.xpi";
              installation_mode = "force_installed";
            };
            "fr-dicollecte@dictionaries.addons.mozilla.org" = {
              install_url = "https://addons.thunderbird.net/thunderbird/downloads/latest/dictionnaire-fran%C3%A7ais1/addon-354872-latest.xpi";
              installation_mode = "force_installed";
            };
          };
        };
      };

      profiles = {
        default = {
          isDefault = true;
          settings = {
            "calendar.timezone.local" = "Europe/Paris";
            "browser.search.region" = "FR";
            "spellchecker.dictionary" = "en-US,fr";
            "mail.server.default.authMethod" = 10;
            "mail.smtpserver.default.authMethod" = 10;
            "mail.rights.version" = 3;
            "datareporting.policy.dataSubmissionPolicyBypassNotification" = true;
            "browser.messaging-system.whatsNewPanel.enabled" = false;
            "browser.newtabpage.activity-stream.asrouter.userprefs.cfr.addons" = false;
            "browser.newtabpage.activity-stream.asrouter.userprefs.cfr.features" = false;
            "browser.preferences.moreFromMozilla" = false;
            "datareporting.healthreport.uploadEnabled" = false;
            "toolkit.telemetry.enabled" = false;
            "toolkit.telemetry.unified" = false;
            "toolkit.telemetry.server" = "";
            "app.update.url.manual" = "";
            "app.update.enabled" = false;
            "app.update.auto" = false;

            # Disable welcome message/screen
            "app.shieldCheckDefaultClient" = false;
            "mailnews.start_page.enabled" = false;
            "mailnews.start_page_override.mstone" = "ignore";
            "messenger.startup.action" = 0;

            # Keep Quick Filter bar visible
            "quickFilterBar.show" = true;

            #NOTE: https://github.com/kewisch/quickmove-extension/issues/158
            "widget.wayland.use-move-to-rect" = false;

            # Use classic table view
            "mail.folder_display_format" = 0;

            # Completely disable preview pane and force tab-based viewing
            "layout.reflow.holdoff" = 0;
            "layout.reflow.holdoff.interval" = 0;
            "layout.reflow.scrolling" = false;
            "mail.pane_config.dynamic" = 0;

            "mailnews.reflow.quote_length" = 0;
            "mail.show_headers" = 1;
            "mailnews.show_preview" = false;
            "mail.tabs.drawInTitlebar" = true;
            "mail.tabs.autoHide" = false;

            # gmail calendar settings
            "calendar.integration.notify" = true;
            "calendar.integration.notify.show" = true;
            "calendar.timezone.useSystemTime" = true;
            "calendar.google.enableAttendees" = true;
            "calendar.google.migrate" = true;
            "calendar.google.useHTTPS" = true;
            "calendar.google.useDefault" = true;

            "accessibility.typeaheadfind.flashBar" = 0;
            "app.donation.eoy.version.viewed" = 6;
            "browser.theme.content-theme" = 0;
            "browser.theme.toolbar-theme" = 0;

            # "general.config.filename" = "dylan.cfg";
            "devtools.debugger.prompt-connection" = false; # Disable the prompt when CTRL + SHIFT + I
            "toolkit.legacyUserProfileCustomizations.stylesheets" = true; # Enable userChrome.css
          };

          userChrome = ''
             /* Hide the tab bar search bar ctrl + K */
             #tabs-toolbar {
                            visibility: collapse !important;
                          }
             #quick-filter-bar {
                display: -moz-box !important;
                visibility: visible !important;
            }


             /* Force the CTRL +SHIFT + K shortcut to open the Quick Filter Bar ON */
                #qfb-sticky {
                    /* Force the sticky button to appear pressed */
                    background-color: var(--button-active-bgcolor) !important;
                    box-shadow: inset 0 1px 1px rgba(0, 0, 0, 0.2) !important;
                }


            #folderTree:focus-within li.selected.unread > .container > .name,
            #folderTree:focus-within li.selected.new-messages > .container > .name {
                color: #a6e3a1 !important;
            }

            [is="tree-view-table-body"]:focus tr[is="thread-row"].selected,
            [is="tree-view-table-body"]:focus-within tr[is="thread-row"].selected,
            [is="tree-view-table-body"] tr[is="thread-row"].selected:focus-within {
                background-color: #a6e3a1 !important;
            }

            .unread > .container > .name,
            .new-messages > .container > .name {
                color: #a6e3a1 !important;
                font-weight: bold !important;
            }

            /* Updated unread count badge styles for better contrast */
            #folderTree:focus-within li.selected > .container > .unread-count,
            .folder-count-badge.unread-count {
                background-color: #a6e3a1 !important;
                color: #1e1e2e !important;  
            }

            *|*:root {
                --folderpane-unread-count-background: #a6e3a1 !important;
                --folderpane-unread-new-count-background: #a6e3a1 !important;
            }

            #folderPaneSplitter:hover,
            #messagePaneSplitter:hover {
                background-color: #a6e3a1 !important;
            }

            splitter[orient="vertical"]:hover,
            splitter[orient="vertical"]:focus {
                border-top: 4px solid #a6e3a1 !important;
            }

            /* Read messages - using Overlay0 (#6c7086) for read messages */
            tr[is="thread-row"]:not(.unread) .subject-line span,
            tr[is="thread-row"]:not(.unread) .correspondentcol-column,
            tr[is="thread-row"]:not(.unread) .datecol-column {
                color: #6c7086 !important;
            }

            /* Unread messages - let's try Text (#cdd6f4) for unread which is clearer but not harsh */
            [is="tree-view-table-body"] tr[is="thread-row"][data-properties~="unread"] .subject-line span,
            [is="tree-view-table-body"] tr[is="thread-row"][data-properties~="unread"] td.correspondentcol-column,
            [is="tree-view-table-body"] tr[is="thread-row"][data-properties~="unread"] td.datecol-column {
                color: #f4dbd6 !important;
                font-weight: bold !important;
            }

          '';
        };
      };

      settings = {
        "mailnewsort_order" = 2;
        "mailnewsews_sort_order" = 2;
        "mailnewsort_type" = 18;
        "mailnewsews_sort_type" = 18;
      };
    };

    accounts.email.accounts = lib.mkMerge [
      (lib.mkIf (accountSecretsExist "thunderbird/account1") {
        gmail = {
          primary = true;
          realName = readSecretFile "thunderbird/account1/name";
          address = readSecretFile "thunderbird/account1/email";
          userName = readSecretFile "thunderbird/account1/email";
          imap = {
            host = "imap.gmail.com";
            port = 993;
            tls.enable = true;
          };
          smtp = {
            host = "smtp.gmail.com";
            port = 587;
            tls.enable = true;
          };
          thunderbird = {
            enable = true;
            profiles = [ "default" ];
            settings = id: {
              "mail.server.server_${id}.authMethod" = 10;
              "mail.server.server_${id}.oauth2.issuer" = "accounts.google.com";
              "mail.server.server_${id}.oauth2.scope" = "https://mail.google.com/ https://www.googleapis.com/auth/carddav https://www.googleapis.com/auth/calendar";
              "mail.smtpserver.smtp_${id}.authMethod" = 10;
              "mail.smtpserver.smtp_${id}.oauth2.issuer" = "accounts.google.com";
              "mail.smtpserver.smtp_${id}.oauth2.scope" = "https://mail.google.com/ https://www.googleapis.com/auth/carddav https://www.googleapis.com/auth/calendar";
            };
          };
        };
      })
      (lib.mkIf (accountSecretsExist "thunderbird/account2") {
        outlook = {
          primary = false;
          realName = readSecretFile "thunderbird/account2/name";
          address = readSecretFile "thunderbird/account2/email";
          userName = readSecretFile "thunderbird/account2/email";
          imap = {
            host = "outlook.office365.com";
            port = 993;
            tls.enable = true;
          };
          smtp = {
            host = "smtp.office365.com";
            port = 587;
            tls.enable = true;
          };
          thunderbird = {
            enable = true;
            profiles = [ "default" ];
            settings = id: {
              "mail.server.server_${id}.authMethod" = 10;
              "mail.server.server_${id}.oauth2.issuer" = "https://login.microsoftonline.com";
              "mail.server.server_${id}.oauth2.scope" = "https://outlook.office365.com/.default";
              "mail.smtpserver.smtp_${id}.authMethod" = 10;
              "mail.smtpserver.smtp_${id}.oauth2.issuer" = "https://login.microsoftonline.com";
              "mail.smtpserver.smtp_${id}.oauth2.scope" = "https://outlook.office365.com/.default";
            };
          };
        };
      })
    ];

    xdg.mimeApps.defaultApplications = {
      "x-scheme-handler/mailto" = [ "thunderbird.desktop" ];
      "x-scheme-handler/mid" = [ "thunderbird.desktop" ];
      "message/rfc822" = [ "thunderbird.desktop" ];
    };
  };
}
