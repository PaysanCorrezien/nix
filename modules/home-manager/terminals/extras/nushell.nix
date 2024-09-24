{ config,settings, lib, pkgs, ... }:

let cfg = settings.terminal.extras;
in {
  config = lib.mkIf cfg.enable {
  programs.nushell = {
    enable = true;

    extraConfig = ''
              let carapace_completer = {|spans|
              carapace $spans.0 nushell $spans | from json
              }

              # Additional configuration
              $env.config = {
                # edit_mode: "vi" # "vi" or "emacs"
                show_banner: false
                   history: {
                max_size: 100_000 # Session has to be reloaded for this to take effect
                sync_on_enter: true # Enable to share history between multiple sessions, else you have to close the session to write history to file
                file_format: "plaintext" # "sqlite" or "plaintext"
                isolation: false # only available with sqlite file_format. true enables history isolation, false disables it. true will allow the history to be isolated to the current session using up/down arrows. false will allow the history to be shared across all sessions.
            }

            completions: {
                case_sensitive: false # set to true to enable case-sensitive completions
                quick: true    # set this to false to prevent auto-selecting completions when only one remains
                partial: true    # set this to false to prevent partial filling of the prompt
                algorithm: "prefix"    # prefix or fuzzy
                sort: "smart" # "smart" (alphabetical for prefix matching, fuzzy score for fuzzy matching) or "alphabetical"
                external: {
                    enable: true # set to false to prevent nushell looking into $env.PATH to find more suggestions, `false` recommended for WSL users as this look up may be very slow
                    max_results: 100 # setting it lower can improve completion performance at the cost of omitting some options
                    completer: null # check 'carapace_completer' above as an example
                }
                use_ls_colors: true # set this to true to enable file/path/directory completions using LS_COLORS
            }
                shell_integration: {
                # osc2 abbreviates the path if in the home_dir, sets the tab/window title, shows the running command in the tab/window title
                osc2: true
                # osc7 is a way to communicate the path to the terminal, this is helpful for spawning new tabs in the same directory
                osc7: true
                # osc8 is also implemented as the deprecated setting ls.show_clickable_links, it shows clickable links in ls output if your terminal supports it. show_clickable_links is deprecated in favor of osc8
                osc8: true
                # osc9_9 is from ConEmu and is starting to get wider support. It's similar to osc7 in that it communicates the path to the terminal
                osc9_9: true
                # osc133 is several escapes invented by Final Term which include the supported ones below.
                # 133;A - Mark prompt start
                # 133;B - Mark prompt end
                # 133;C - Mark pre-execution
                # 133;D;exit - Mark execution finished with exit code
                # This is used to enable terminals to know where the prompt is, the command is, where the command finishes, and where the output of the command is
                osc133: true
                # osc633 is closely related to osc133 but only exists in visual studio code (vscode) and supports their shell integration features
                # 633;A - Mark prompt start
                # 633;B - Mark prompt end
                # 633;C - Mark pre-execution
                # 633;D;exit - Mark execution finished with exit code
                # 633;E - Explicitly set the command line with an optional nonce
                # 633;P;Cwd=<path> - Mark the current working directory and communicate it to the terminal
                # and also helps with the run recent menu in vscode
                osc633: true
                # reset_application_mode is escape \x1b[?1l and was added to help ssh work better
                reset_application_mode: true
            }
            render_right_prompt_on_last_line: false # true or false to enable or disable right prompt to be rendered on last line of the prompt.
                use_kitty_protocol: true # enables keyboard enhancement protocol implemented by kitty console, only if your terminal support this.
            highlight_resolved_externals: true # true enables highlighting of external commands in the repl resolved by which.



              }
              # https://yazi-rs.github.io/docs/quick-start/#shell-wrapper
              def --env y [...args] {
            	let tmp = (mktemp -t "yazi-cwd.XXXXXX")
             	yazi ...$args --cwd-file $tmp
             	let cwd = (open $tmp)
             	if $cwd != "" and $cwd != $env.PWD {
             		cd $cwd
             	rm -fp $tmp
      }
              $env.STARSHIP_SHELL = "nushell"
              $env.STARSHIP_CONFIG = ([$env.HOME, ".config", "starship", "starship.toml"] | path join)
    '';
  #TODO: all the keybindings

    shellAliases = {
      n = "nvim";
      y = "yazi";
      # sw = "~/.config/nix/scripts/rebuild.sh";
    };
  };
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
  services.gpg-agent.enableNushellIntegration = true;
  };

}
