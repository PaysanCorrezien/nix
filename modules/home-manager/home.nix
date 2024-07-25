# home.nix
{ lib, config, pkgs, inputs, settings, ... }:
let
  isServer = settings.isServer;
  # Function to write settings to $HOME/.settings.nix
  # Serialize the settings to JSON
  # NOTE: dump all settings to ~/.settings.nix.json to troubleshoot
  serializedSettings = builtins.toJSON settings;
  settingsFilePath = "${config.home.homeDirectory}/.settings.nix.json";
  # Create a writable copy of the settings file
  setPermissionsScript = ''
    rm -f ${settingsFilePath}
    cp ${settingsFilePath}.init ${settingsFilePath}
    chmod u+w ${settingsFilePath}
  '';
in {
  imports = [ # Configuration via home.nix
    ./programs/nextloud-cli.nix
    ./graphical/gui.nix
    ./mime-type.nix
    ./gnome/keybinds.nix
    ../chezmoi/chezmoi.nix
    ./browser/firefox.nix
    ./terminals/default.nix
    ./terminals/zsh.nix
    # ./terminals/fonts.nix
    # ./terminals/rust.nix
    ./gnome/extensions.nix
    ./gnome/settings.nix
    ./programs/nvim.nix
    ./programs/keepassxc.nix
    ./programs/keybswitch.nix
    ./programs/wezterm.nix
    ./programs/virtualisation.nix

  ];
  # Home Manager needs a bit of information about you and the paths it should
  # manage.
  home.username = "dylan";
  home.homeDirectory = "/home/dylan";

  # Write the settings to an initial file in the home directory
  home.file.".settings.nix.json.init".text = serializedSettings;
  home.activation.setSettingsPermissions =
    lib.hm.dag.entryAfter [ "writeTextFile" ] ''
      ${setPermissionsScript}
    '';

  #FIXME: print nothing
  home.sessionVariables = { IS_SERVER = toString isServer; };
  # This value determines the Home Manager release that your configuration is
  # compatible with. This helps avoid breakage when a new Home Manager release
  # introduces backwards incompatible changes.
  #
  # You should not change this value, even if you update Home Manager. If you do
  # want to update the value, then make sure to first check the Home Manager
  # release notes.
  home.stateVersion = "23.11"; # Please read the comment before changing.

  # Home Manager is pretty good at managing dotfiles. The primary way to manage
  # plain files is through 'home.file'.
  home.file = {
    # # Building this configuration will create a copy of 'dotfiles/screenrc' in
    # # the Nix store. Activating the configuration will then make '~/.screenrc' a
    # # symlink to the Nix store copy.
    # ".screenrc".source = dotfiles/screenrc;

    # # You can also set the file content immediately.
    # ".gradle/gradle.properties".text = ''
    #   org.gradle.console=verbose
    #   org.gradle.daemon.idletimeout=3600000
    # '';
  };

  # Home Manager can also manage your environment variables through
  # 'home.sessionVariables'. If you don't want to manage your shell through Home
  # Manager then you have to manually source 'hm-session-vars.sh' located at
  # either
  #
  #  ~/.nix-profile/etc/profile.d/hm-session-vars.sh
  #
  # or
  #
  #  ~/.local/state/nix/profiles/profile/etc/profile.d/hm-session-vars.sh
  #
  # or
  #
  #  /etc/profiles/per-user/dylan/etc/profile.d/hm-session-vars.sh
  #
  home.sessionVariables = {
    EDITOR = "nvim";
    # LD_LIBRARY_PATH = lib.concatStringsSep ":" ([
    #   "${pkgs.sqlite}/lib"
    # ] ++ lib.optional (config.home.sessionVariables ? LD_LIBRARY_PATH) config.home.sessionVariables.LD_LIBRARY_PATH);
  };
  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
}
