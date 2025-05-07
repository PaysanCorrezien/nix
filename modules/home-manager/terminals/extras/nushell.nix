{
  config,
  settings,
  lib,
  pkgs,
  ...
}:
let
  cfg = settings.terminal.extras;
in
{
  config = lib.mkIf cfg.enable {
    programs.nushell = {
      package = pkgs.nushell.override {
        withDefaultFeatures = true;
        #additionalFeatures = oldFeatures: oldFeatures ++ [ "system-clipboard" ];
      };
      enable = true;

      extraConfig = ''

        # Carapace completion configuration
        let carapace_completer = {|spans|
            carapace $spans.0 nushell ...$spans | from json
        }

        # Load keybindings from file
        source ~/.config/nushell/keybindings.nu
        source ~/.config/nushell/menus.nu

        # Main environment configuration
        $env.config = {
            show_banner: false
            history: {
                max_size: 100000
                sync_on_enter: true
                file_format: "plaintext"
                isolation: false
            }
            #NOTE: from external files
            keybindings: $keybindings
            menus: $menus


            completions: {
                case_sensitive: false
                quick: true
                partial: true
                algorithm: "prefix"
                sort: "smart"
                external: {
                    enable: true
                    max_results: 100
                    completer: $carapace_completer
                }
                use_ls_colors: true
            }
            shell_integration: {
                osc2: true
                osc7: true
                osc8: true
                osc9_9: true
                osc133: true
                osc633: true
                reset_application_mode: true
            }
            render_right_prompt_on_last_line: false
            use_kitty_protocol: true
            highlight_resolved_externals: true
        }
        # Yazi file manager integration
        def --env y [...args] {
            let tmp = (mktemp -t "yazi-cwd.XXXXXX")
            yazi ...$args --cwd-file $tmp
            let cwd = (open $tmp)
            if $cwd != "" and $cwd != $env.PWD {
                cd $cwd
            }
            rm -fp $tmp
        }
        # Starship prompt configuration
        $env.STARSHIP_SHELL = "nushell"
        $env.STARSHIP_CONFIG = ([$env.HOME, ".config", "starship", "starship.toml"] | path join)
        # Source Atuin history sync
        # source ~/.cache/atuin/init.nu
      '';
    };
    xdg.configFile."nushell/keybindings.nu".source = ./nushell/keybindings.nu;
    xdg.configFile."nushell/menus.nu".source = ./nushell/menus.nu;
    # Enable zoxide
    programs.zoxide = {
      enable = true;
      enableNushellIntegration = true;
    };
    # Enable Starship
    programs.starship = {
      enable = true;
      enableNushellIntegration = true;
    };
    home.packages = with pkgs; [
      nushellPlugins.query
      nushellPlugins.gstat
      nushellPlugins.polars
      nushellPlugins.formats
      nufmt
    ];
    programs.yazi.enableNushellIntegration = true;
    programs.atuin.enableNushellIntegration = true;
    services.gpg-agent.enableNushellIntegration = true;
  };
}
