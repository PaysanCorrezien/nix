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

  # Function to read a secret file and convert it to an integer
  readSecretFileAsInt =
    name:
    let
      content = readSecretFile name;
    in
    if content == "" then null else lib.toInt content;

  # Function to check if all required secrets for an account exist
  accountSecretsExist =
    prefix: (readSecretFile "${prefix}/name") != "" && (readSecretFile "${prefix}/email") != "";

  # Only define accounts if secrets exist
  account1 =
    if accountSecretsExist "thunderbird/account1" then
      {
        name = readSecretFile "thunderbird/account1/name";
        email = readSecretFile "thunderbird/account1/email";
      }
    else
      null;

  account2 =
    if accountSecretsExist "thunderbird/account2" then
      {
        name = readSecretFile "thunderbird/account2/name";
        email = readSecretFile "thunderbird/account2/email";
      }
    else
      null;

  # Function to create an email account configuration
  mkEmailAccount = account: name: {
    ${name} = {
      primary = name == "gmail";
      address = account.email;
      realName = account.name;
      userName = account.email;
      imap = {
        host = if name == "gmail" then "imap.gmail.com" else "outlook.office365.com";
        port = if name == "gmail" then 993 else 993;
        tls.enable = true;
      };
      smtp = {
        host = if name == "gmail" then "smtp.gmail.com" else "smtp.office365.com";
        port = 587;
        tls.enable = true;
      };
      thunderbird = {
        enable = true;
        profiles = [ "default" ];
        settings = id: {
          "mail.server.server_${id}.authMethod" = 10;
          "mail.server.server_${id}.oauth2.issuer" =
            if name == "gmail" then "accounts.google.com" else "https://login.microsoftonline.com";
          "mail.server.server_${id}.oauth2.scope" =
            if name == "gmail" then
              "https://mail.google.com/ https://www.googleapis.com/auth/carddav https://www.googleapis.com/auth/calendar"
            else
              "https://outlook.office365.com/.default";
          "mail.smtpserver.smtp_${id}.authMethod" = 10;
          "mail.smtpserver.smtp_${id}.oauth2.issuer" =
            if name == "gmail" then "accounts.google.com" else "https://login.microsoftonline.com";
          "mail.smtpserver.smtp_${id}.oauth2.scope" =
            if name == "gmail" then
              "https://mail.google.com/ https://www.googleapis.com/auth/carddav https://www.googleapis.com/auth/calendar"
            else
              "https://outlook.office365.com/.default";
        };
      };
    };
  };

  # Create email accounts only if secrets exist
  emailAccounts =
    (if account1 != null then mkEmailAccount account1 "gmail" else { })
    // (if account2 != null then mkEmailAccount account2 "outlook" else { });

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
            "tbkeys@addons.thunderbird.net" = {
              install_url = "https://github.com/wshanks/tbkeys/releases/latest/download/tbkeys.xpi";
              installation_mode = "force_installed";
            };
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

    accounts.email.accounts = emailAccounts;

    xdg.mimeApps.defaultApplications = {
      "x-scheme-handler/mailto" = [ "thunderbird.desktop" ];
      "x-scheme-handler/mid" = [ "thunderbird.desktop" ];
      "message/rfc822" = [ "thunderbird.desktop" ];
    };
  };
}
