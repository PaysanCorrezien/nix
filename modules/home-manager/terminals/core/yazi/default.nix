{
  lib,
  pkgs,
  config,
  yaziPlugins,
  ...
}:
#NOTE: the plugins are provided via https://github.com/lordkekz/nix-yazi-plugins
let

  # NOTE: ship the ttermfilechooser backend for xdg-desktop-portal

  mkYaziPlugin = name: text: {
    "${name}" = toString (pkgs.writeTextDir "${name}.yazi/init.lua" text) + "/${name}.yazi";
  };
  #NOTE: make the keyjump plugin available
  keyjumpPlugin = pkgs.runCommandLocal "keyjump.yazi" { } ''
    mkdir -p $out
    cp ${./keyjump.lua} $out/init.lua
  '';

  # search-jump = import ./search-jump.nix { inherit lib pkgs config; };
  homeDir = config.home.homeDirectory;

  shortcuts = {
    h = homeDir;
    dots = "${homeDir}/.local/share/chezmoi";
    cfg = "${homeDir}/.config";
    vd = "${homeDir}/Videos";
    pp = "${homeDir}/projects";
    pc = "${homeDir}/Images";
    pw = "${homeDir}/Images/Wallpapers";
    dd = "${homeDir}/Téléchargements";
    rp = "${homeDir}/repo";
  };

in
lib.mkMerge [
  # search-jump
  {
    home.packages = with pkgs; [
      miller
      zenity
      ouch
      zoxide
      ueberzugpp
      unar
      glow
      exiftool
      clipboard-jh # https://github.com/Slackadays/ClipBoard
      trash-cli
      exiftool
      mediainfo
    ];

    programs.yazi = {
      enable = true;
      enableZshIntegration = true;
      plugins = pkgs.yaziPlugins;

      initLua = ''
                function Linemode:size_and_mtime()
                  local time = (self._file.cha and self._file.cha.modified or 0) // 1
                  local timestr
                  if time > 0 then
                    timestr = os.date("%d/%m/%y %H:%M", time)
                  else
                    timestr = ""
                  end

                  local size = self._file:size()
                  local sizestr
                  if not size or size == 0 then
                    sizestr = "0 B"
                  elseif size < 1024 then
                    sizestr = string.format("%d B", size)
                  elseif size < 1024 * 1024 then
                    sizestr = string.format("%.2f KB", size / 1024)
                  else
                    sizestr = string.format("%.2f MB", size / (1024 * 1024))
                  end

                  return ui.Line(string.format(" %s | %s ", sizestr, timestr))
                end

                --NOTE: for the fullborder plugin:
                require("full-border"):setup {
                	-- Available values: ui.Border.PLAIN, ui.Border.ROUNDED
                	type = ui.Border.ROUNDED,
                }

                --NOTE: https://yazi-rs.github.io/docs/tips/#user-group-in-status
                Status:children_add(function()
        	local h = cx.active.current.hovered
        	if h == nil or ya.target_family() ~= "unix" then
        		return ui.Line {}
        	end

        	return ui.Line {
        		ui.Span(ya.user_name(h.cha.uid) or tostring(h.cha.uid)):fg("magenta"),
        		ui.Span(":"),
        		ui.Span(ya.group_name(h.cha.gid) or tostring(h.cha.gid)):fg("magenta"),
        		ui.Span(" "),
        	}
        end, 500, Status.RIGHT)
        --NOTE: for the copy-file-contents plugin:
                require("copy-file-contents"):setup({
        	clipboard_cmd = "default",
        	append_char = "\n",
        	notification = true,
        })
        -- note: for the starship plugin
        require("starship"):setup()
      '';

      settings = {
        manager = {
          show_hidden = true;
          sort_by = "modified";
          sort_dir_first = false;
          sort_reverse = true;
          linemode = "size_and_mtime";
        };
        preview = {
          max_width = 1920;
          max_height = 1080;
        };
        log = {
          enabled = true;
        };
        previewers = {
          prepend = [
            {
              mime = "application/*zip";
              run = "ouch";
            }
            {
              mime = "application/x-tar";
              run = "ouch";
            }
            {
              mime = "application/x-bzip2";
              run = "ouch";
            }
            {
              mime = "application/x-7z-compressed";
              run = "ouch";
            }
            {
              mime = "application/x-rar";
              run = "ouch";
            }
            {
              mime = "application/x-xz";
              run = "ouch";
            }
          ];
        };
        plugin = {
          prepend_previewers = [
            {
              #NOTE: https://github.com/Reledia/glow.yazi
              name = "*.md";
              run = "glow";
            }
            {
              #NOTE: https://github.com/Sonico98/exifaudio.yazi
              mime = "audio/*";
              run = "exifaudio";
            }
            {
              #NOTE: https://github.com/AnirudhG07/rich-preview.yazi
              name = "*.csv";
              run = "rich-preview";
            }
            {
              name = "*.rst";
              run = "rich-preview";
            }
            {
              name = "*.ipynb";
              run = "rich-preview";
            }
            {
              name = "*.json";
              run = "rich-preview";
            }

          ];
        };
      };

      theme = {
        manager = {
          preview_hovered = {
            underline = true;
          };
        };
      };

      #NOTE: keymap example credit : https://github.com/iynaix/dotfiles/blob/main/home-manager/shell/yazi.nix
      keymap = {
        manager.prepend_keymap =
          [
            #NOTE:  https://github.com/AnirudhG07/plugins-yazi/tree/main/copy-file-contents.yazi
            {
              on = [
                "c"
                "C"
              ];
              run = [ "plugin copy-file-contents" ];
              desc = "Copy contents of file";
            }
            #NOTE:  https://github.com/ndtoan96/ouch.yazi
            # ya pack -a ndtoan96/ouch                                                                                                                                                                              
            {
              on = [
                "c"
                "Z"
              ];
              run = [ "plugin ouch --args=zip" ];
              desc = "Zip the selected files";
            }

            # Change directory to the root of the Git repository
            {
              on = [
                "g"
                "r"
              ];
              run = ''shell 'ya pub dds-cd --str "$(git rev-parse --show-toplevel)"' --confirm'';
              desc = "Cd to root of current Git repo";
            }
          ]
          ++ lib.flatten (
            lib.mapAttrsToList (keys: loc: [
              # cd
              {
                on = [ "g" ] ++ lib.stringToCharacters keys;
                run = "cd ${loc}";
                desc = "cd to ${loc}";
              }
              # new tab
              {
                on = [ "t" ] ++ lib.stringToCharacters keys;
                run = "tab_create ${loc}";
                desc = "open new tab to ${loc}";
              }
              # mv
              {
                on = [ "m" ] ++ lib.stringToCharacters keys;
                run = [
                  "yank --cut"
                  "escape --visual --select"
                  loc
                ];
                desc = "move selection to ${loc}";
              }
              # cp
              {
                on = [ "Y" ] ++ lib.stringToCharacters keys;
                run = [
                  "yank"
                  "escape --visual --select"
                  loc
                ];
                desc = "copy selection to ${loc}";
              }
            ]) shortcuts
          )
          ++ [
            # # Additional shortcut for wallpapers with 'gW'
            # NOTE: keep at syntaxe pplaceholder
            {
              on = [
                "g"
                "W"
              ];
              run = "cd ${shortcuts.pw}";
              desc = "Go to Wallpapers directory";
            }
            {
              on = [
                "t"
                "t"
              ];
              run = "tab_create";
              desc = "open new tab in current directory";
            }
            #NOTE: maybe later ?
            # # Additional ZFS-related bindings
            # {
            #   on = [
            #     "z"
            #     "h"
            #   ];
            #   run = "plugin zfs --args=prev";
            #   desc = "Go to previous ZFS snapshot";
            # }
            # {
            #   on = [
            #     "z"
            #     "l"
            #   ];
            #   run = "plugin zfs --args=next";
            #   desc = "Go to next ZFS snapshot";
            # }
            # {
            #   on = [
            #     "z"
            #     "e"
            #   ];
            #   run = "plugin zfs --args=exit";
            #   desc = "Exit browsing ZFS snapshots";
            # }
          ];
      };
    };

  }

  # smart-enter: enter for directory, open for file
  {
    programs.yazi = {
      plugins = mkYaziPlugin "smart-enter" ''
        return {
          entry = function()
            local h = cx.active.current.hovered
            ya.manager_emit(h and h.cha.is_dir and "enter" or "open", { hovered = true })
          end,
        }
      '';
      keymap.manager.prepend_keymap = [
        {
          on = "l";
          run = "plugin --sync smart-enter";
          desc = "Enter the child directory, or open the file";
        }
      ];
    };
  }

  # smart-paste: paste files without entering the directory
  {
    programs.yazi = {
      plugins = mkYaziPlugin "smart-paste" ''
        return {
          entry = function()
            local h = cx.active.current.hovered
            if h and h.cha.is_dir then
              ya.manager_emit("enter", {})
              ya.manager_emit("paste", {})
              ya.manager_emit("leave", {})
            else
              ya.manager_emit("paste", {})
            end
          end,
        }
      '';
      keymap.manager.prepend_keymap = [
        {
          on = "p";
          run = "plugin --sync smart-paste";
          desc = "Paste into the hovered directory or CWD";
        }
      ];
    };
  }

  # arrow: file navigation wraparound
  {
    programs.yazi = {
      plugins = mkYaziPlugin "arrow" ''
        return {
          entry = function(_, args)
            local current = cx.active.current
            local new = (current.cursor + args[1]) % #current.files
            ya.manager_emit("arrow", { new - current.cursor })
          end,
        }
      '';
      keymap.manager.prepend_keymap = [
        {
          on = "k";
          run = "plugin --sync arrow --args=-1";
        }
        {
          on = "j";
          run = "plugin --sync arrow --args=1";
        }
      ];
    };
  }
  {
    programs.yazi = {
      # https://github.com/yazi-rs/plugins/tree/main/max-preview.yazi
      keymap.manager.prepend_keymap = [
        {
          on = "T";
          run = "plugin --sync max-preview";
          desc = "Maximize or restore preview";
        }
      ];
    };
  }

  {
    programs.yazi = {
      # https://github.com/orhnk/system-clipboard.yazi
      keymap.manager.prepend_keymap = [
        {
          on = "<C-y>";
          run = [ "plugin system-clipboard" ];
          desc = "Copy selected files to system clipboard";

        }
      ];
    };
  }

  {
    programs.yazi = {
      # https://github.com/yazi-rs/plugins/tree/main/
      keymap.manager.prepend_keymap = [
        {
          on = [
            "c"
            "m"
          ];
          run = "plugin chmod";
          desc = "Chmod on selected files";
        }
      ];
    };
  }

  {
    programs.yazi = {
      # https://github.com/yazi-rs/plugins/tree/main/full-border.yazi
      keymap.manager.prepend_keymap = [
        {
          on = "T";
          run = "plugin --sync max-preview";
          desc = "Maximize or restore preview";
        }
      ];
    };
  }
  {
    #NOTE: https://gitee.com/DreamMaoMao/keyjump.yazi
    # offer hop.nvim / tridactyl like nav
    programs.yazi = {
      plugins = {
        # Your existing plugins...
        keyjump = keyjumpPlugin; # Add this line
      };
      keymap.manager.prepend_keymap = [
        {
          on = [
            "f"
          ];
          run = "plugin keyjump --args='global once'";
          desc = "Keyjump (once Global mode)";
        }
      ];
    };
  }

  {
    # xdg.configFile."xdg-desktop-portal-termfilechooser/config".text = ''
    #   [filechooser]
    #   cmd=${pkgs.yazi}/bin/yazi
    #   default_dir=$HOME
    # '';

    xdg.dataFile."applications/yazi.desktop".text = ''
      [Desktop Entry]
      Name=Yazi
      Icon=yazi
      Comment=Blazing fast terminal file manager written in Rust, based on async I/O
      Terminal=true
      TryExec=yazi
      Exec=yazi %U
      Type=Application
      MimeType=inode/directory
      Categories=Utility;Core;System;FileTools;FileManager;ConsoleOnly
      Keywords=File;Manager;Explorer;Browser;Launcher
    '';
    xdg.mimeApps = {
      enable = true;
      defaultApplications = {
        "inode/directory" = "yazi.desktop";
        "x-directory/normal" = "yazi.desktop";
        "x-directory/gnome-default-handler" = "yazi.desktop";
        "x-scheme-handler/file" = "yazi.desktop";
        "application/x-directory" = "yazi.desktop";
        "application/x-gnome-saved-search" = "yazi.desktop";
      };
    };
  }

  #NOTE: configure xdg-desktop-portal-termfilechooser for yazi
  # {
  #   xdg.configFile."xdg-desktop-portal-termfilechooser/yazi-wrapper.sh" = {
  #     text = ''
  #       #!/usr/bin/env bash
  #       CWD="''${1:-$HOME}"
  #       CHOICES_FILE="''${2}"
  #
  #       TERM_CMD=''${TERMCMD:-"${pkgs.wezterm}/bin/wezterm"}
  #
  #       if [ -n "$TERM_CMD" ]; then
  #         $TERM_CMD -- ${pkgs.yazi}/bin/yazi --chooser-file "$CHOICES_FILE" "$CWD"
  #       else
  #         ${pkgs.yazi}/bin/yazi --chooser-file "$CHOICES_FILE" "$CWD"
  #       fi
  #     '';
  #     executable = true;
  #   };
  #
  #   # Explicitly disable FileChooser in other portals
  #
  #   xdg.configFile."xdg-desktop-portal/portals/gtk.portal".text = ''
  #     [portal]
  #     DBusName=org.freedesktop.impl.portal.desktop.gtk
  #     Interfaces=org.freedesktop.impl.portal.Settings;org.freedesktop.impl.portal.Screenshot
  #     UseIn=gtk
  #   '';
  #
  #   systemd.user.services.xdg-desktop-portal-termfilechooser = {
  #     Unit = {
  #       Description = "Terminal file chooser portal";
  #       PartOf = [ "graphical-session.target" ];
  #       After = [ "graphical-session.target" ];
  #     };
  #     Service = {
  #       Type = "dbus";
  #       BusName = "org.freedesktop.impl.portal.desktop.termfilechooser";
  #       ExecStart = "${pkgs.xdg-desktop-portal-termfilechooser}/libexec/xdg-desktop-portal-termfilechooser -l DEBUG";
  #       Environment = [
  #         "GTK_USE_PORTAL=1"
  #         "XDG_CURRENT_DESKTOP=termfilechooser:GNOME" # Add our desktop first
  #         "TERMFILECHOOSER_PRIORITY=999"
  #       ];
  #       Restart = "on-failure";
  #     };
  #     Install = {
  #       WantedBy = [ "graphical-session.target" ];
  #     };
  #   };
  #
  #   # Add to your session variables
  #   home.sessionVariables = {
  #     GTK_USE_PORTAL = "1";
  #     GDK_DEBUG = "portals";
  #     XDG_CURRENT_DESKTOP = "termfilechooser:GNOME"; # Add our desktop first
  #   };
  #
  #   # Update portal config
  #   xdg.configFile."xdg-desktop-portal/portals/termfilechooser.portal".text = ''
  #     [portal]
  #     DBusName=org.freedesktop.impl.portal.desktop.termfilechooser
  #     Interfaces=org.freedesktop.impl.portal.FileChooser
  #     UseIn=gnome;gtk;*
  #     Priority=999
  #   '';
  #
  #   # This is the key: we'll modify the gnome portal configuration
  #   xdg.configFile."xdg-desktop-portal/portals/gnome.portal".text = ''
  #     [portal]
  #     DBusName=org.freedesktop.impl.portal.desktop.gnome
  #     Interfaces=org.freedesktop.impl.portal.Account;org.freedesktop.impl.portal.Screenshot;org.freedesktop.impl.portal.ScreenCast;org.freedesktop.impl.portal.RemoteDesktop;org.freedesktop.impl.portal.Inhibit;org.freedesktop.impl.portal.Notification;org.freedesktop.impl.portal.Background;org.freedesktop.impl.portal.Settings;org.freedesktop.impl.portal.GameMode;org.freedesktop.impl.portal.AppChooser;org.freedesktop.impl.portal.Print;org.freedesktop.impl.portal.Lockdown;org.freedesktop.impl.portal.Wallpaper;org.freedesktop.impl.portal.InputCapture
  #     UseIn=gnome;*
  #   '';
  #
  #   xdg.configFile."xdg-desktop-portal/portals.conf".text = ''
  #     [preferred]
  #     default=termfilechooser
  #     org.freedesktop.impl.portal.FileChooser=termfilechooser
  #
  #     [various]
  #     termfilechooser=999
  #   '';
  # }
]
