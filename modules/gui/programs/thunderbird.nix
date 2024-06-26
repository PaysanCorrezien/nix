{ config, pkgs, ... }:

{
  programs.thunderbird = {
    enable = true;
    settings = {
          # General settings
          "mail.shell.checkDefaultClient" = false;
          "mail.tabs.autoHide" = false;
          "mailnews.default_sort_order" = 2;  # Sort by date descending (most recent first)
          "mail.showCondensedAddresses" = true;
    
          # Layout settings
          "mail.pane_config.dynamic" = 0;  # 0: vertical, 1: horizontal, 2: wide
          "mail.start_page.enabled" = false;  # Disable start page
          "mailnews.display.html_as" = 1;  # 0: HTML, 1: Simple HTML, 2: Plain text
    
          # Performance settings
          "mail.db.idle_limit" = 30;  # Compact folders when Thunderbird is idle for 30 seconds
          "mail.imap.use_status_for_biff" = true;  # More efficient checking for new messages
    
          # Reading settings
          "mailnews.mark_message_read.delay" = true;  # Enable delay before marking as read
          "mailnews.mark_message_read.delay.interval" = 5;  # 5 second delay
    
          # Compose settings
          "mail.identity.default.compose_html" = false;  # Compose in plain text by default
          "mail.compose.autosave" = true;  # Enable autosave while composing
          "mail.compose.autosaveinterval" = 3;  # Autosave every 3 minutes
        };
    
        # Keybindings
        extraConfig = ''
          user_pref("mail.keyboard.enable_shortcuts", true);
          user_pref("mail.key_archive", "A");
          user_pref("mail.key_delete", "D");
          user_pref("mail.key_forward", "F");
          user_pref("mail.key_reply", "R");
          user_pref("mail.key_replyall", "Shift+R");
          user_pref("mail.key_toggleRead", "M");
          user_pref("mail.key_mark_as_junk", "J");
          user_pref("mail.key_mark_as_not_junk", "Shift+J");
          user_pref("mail.key_newMessage", "N");
          user_pref("mail.key_tag", "T");
          user_pref("mail.key_undelete", "Z");
        '';

    profiles = {
      default = {
        isDefault = true;
        name = "Default";
        settings = {
          # First account
          "mail.accountmanager.accounts" = "account1,account2";
          "mail.account.account1.server" = "server1";
          "mail.account.account1.name" = "Your Name";
          "mail.account.account1.identities" = "id1";
          "mail.identity.id1.fullName" = "Your Full Name";
          "mail.identity.id1.useremail" = "your.email@example.com";
          "mail.server.server1.hostname" = "mail.example.com";
          "mail.server.server1.type" = "imap";
          "mail.server.server1.port" = 993;
          "mail.server.server1.socketType" = 3;  # SSL/TLS
          "mail.server.server1.username" = "your.email@example.com";

          # Second account
          "mail.account.account2.server" = "server2";
          "mail.account.account2.name" = "Your Other Name";
          "mail.account.account2.identities" = "id2";
          "mail.identity.id2.fullName" = "Your Other Full Name";
          "mail.identity.id2.useremail" = "your.other.email@example.com";
          "mail.server.server2.hostname" = "mail.otherexample.com";
          "mail.server.server2.type" = "imap";
          "mail.server.server2.port" = 993;
          "mail.server.server2.socketType" = 3;  # SSL/TLS
          "mail.server.server2.username" = "your.other.email@example.com";
        };
      };
    };
  };
}
