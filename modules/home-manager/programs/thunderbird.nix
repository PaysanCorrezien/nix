{ config, pkgs, lib, ... }:

let
  thunderbirdSecretsPath = "/run/secrets";

  # Function to read a secret file and return its content or an empty string
  readSecretFile = name:
    let path = "${thunderbirdSecretsPath}/${name}";
    in if builtins.pathExists path then builtins.readFile path else "";

  # Function to read a secret file and convert it to an integer
  readSecretFileAsInt = name:
    let content = readSecretFile name;
    in if content == "" then null else lib.toInt content;

  account1 = {
    name = readSecretFile "thunderbird/account1/name";
    email = readSecretFile "thunderbird/account1/email";
    server = readSecretFile "thunderbird/account1/server";
    port = readSecretFileAsInt "thunderbird/account1/port";
    username = readSecretFile "thunderbird/account1/username";
  };

  account2 = {
    name = readSecretFile "thunderbird/account2/name";
    email = readSecretFile "thunderbird/account2/email";
    server = readSecretFile "thunderbird/account2/server";
    port = readSecretFileAsInt "thunderbird/account2/port";
    username = readSecretFile "thunderbird/account2/username";
  };

in {
  programs.thunderbird = {
    enable = true;
    package = pkgs.thunderbird.override {
      extraPolicies = {
        ExtensionSettings = {
          "*".installation_mode = "blocked";
          "owl@beonex.com" = {
            install_url =
              "https://addons.thunderbird.net/thunderbird/downloads/latest/owl-for-exchange/latest.xpi";
            installation_mode = "force_installed";
          };
          "{a62ef8ec-5fdc-40c2-873c-223b8a6925cc}" = {
            install_url =
              "https://addons.thunderbird.net/thunderbird/downloads/latest/provider-for-google-calendar/latest.xpi";
            installation_mode = "force_installed";
          };
          "tbkeys@addons.thunderbird.net" = {
            install_url =
              "https://github.com/wshanks/tbkeys/releases/latest/download/tbkeys.xpi";
            installation_mode = "force_installed";
          };
          "{f6d05f0c-39a8-5c4d-96dd-4852202a8244}" = {
            install_url =
              "https://raw.githubusercontent.com/catppuccin/thunderbird/main/themes/mocha/mocha-blue.xpi";
            installation_mode = "force_installed";
          };
          "fr-dicollecte@dictionaries.addons.mozilla.org" = {
            install_url =
              "https://addons.thunderbird.net/thunderbird/downloads/latest/dictionnaire-fran%C3%A7ais1/addon-354872-latest.xpi";
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

          # Disable opening of privacy settings
          "datareporting.policy.dataSubmissionPolicyBypassNotification" = true;

          # Additional settings to enhance privacy and remove unnecessary prompts
          "browser.messaging-system.whatsNewPanel.enabled" = false;
          "browser.newtabpage.activity-stream.asrouter.userprefs.cfr.addons" =
            false;
          "browser.newtabpage.activity-stream.asrouter.userprefs.cfr.features" =
            false;
          "browser.preferences.moreFromMozilla" = false;
          "datareporting.healthreport.uploadEnabled" = false;
          "toolkit.telemetry.enabled" = false;
          "toolkit.telemetry.unified" = false;
          "toolkit.telemetry.server" = "";
        };
      };
    };

    settings = {
      "mailnews.default_sort_order" = 2;
      "mailnews.default_news_sort_order" = 2;
      "mailnews.default_sort_type" = 18;
      "mailnews.default_news_sort_type" = 18;
    };
  };

  accounts.email.accounts = {
    gmail = {
      primary = true;
      address = account1.email;
      realName = account1.name;
      userName = account1.email;
      imap = {
        host = account1.server;
        port = account1.port;
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
          "mail.server.server_${id}.oauth2.scope" =
            "https://mail.google.com/ https://www.googleapis.com/auth/carddav https://www.googleapis.com/auth/calendar";
          "mail.smtpserver.smtp_${id}.authMethod" = 10;
          "mail.smtpserver.smtp_${id}.oauth2.issuer" = "accounts.google.com";
          "mail.smtpserver.smtp_${id}.oauth2.scope" =
            "https://mail.google.com/ https://www.googleapis.com/auth/carddav https://www.googleapis.com/auth/calendar";
        };
      };
    };
    outlook = {
      address = account2.email;
      realName = account2.name;
      userName = account2.email; # Changed back to email as per the screenshot
      imap = {
        host = "outlook.office365.com"; # Updated hostname
        port = 993; # Updated port
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
          "mail.server.server_${id}.authMethod" = 10; # 10 corresponds to OAuth2
          "mail.server.server_${id}.oauth2.issuer" =
            "https://login.microsoftonline.com";
          "mail.server.server_${id}.oauth2.scope" =
            "https://outlook.office365.com/.default";
          "mail.smtpserver.smtp_${id}.authMethod" =
            10; # 10 corresponds to OAuth2
          "mail.smtpserver.smtp_${id}.oauth2.issuer" =
            "https://login.microsoftonline.com";
          "mail.smtpserver.smtp_${id}.oauth2.scope" =
            "https://outlook.office365.com/.default";
        };
      };
    };
  };

  xdg.mimeApps.defaultApplications = {
    "x-scheme-handler/mailto" = [ "thunderbird.desktop" ];
    "x-scheme-handler/mid" = [ "thunderbird.desktop" ];
    "message/rfc822" = [ "thunderbird.desktop" ];
  };
}
