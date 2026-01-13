# Unified Yazi configuration (minimal, works for desktop, server, and WSL)
{
  lib,
  pkgs,
  config,
  ...
}:
let
  homeDir = config.home.homeDirectory;

  shortcuts = {
    h = homeDir;
    cfg = "${homeDir}/.config";
    vd = "${homeDir}/Videos";
    pp = "${homeDir}/projects";
    pc = "${homeDir}/Images";
    rp = "${homeDir}/repo";
  };

in
lib.mkMerge [
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
      trash-cli
      mediainfo
    ];

    programs.yazi = {
      enable = true;
      enableZshIntegration = true;
      plugins = { };

      initLua = ''
        function Linemode:size_and_mtime()
          local time = (self._file.cha and self._file.cha.mtime or 0) // 1
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
      '';

      settings = {
        manager = {
          show_hidden = true;
          sort_by = "mtime";
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
            { mime = "application/zip"; run = "ouch"; }
            { mime = "application/tar"; run = "ouch"; }
            { mime = "application/bzip2"; run = "ouch"; }
            { mime = "application/7z-compressed"; run = "ouch"; }
            { mime = "application/rar"; run = "ouch"; }
            { mime = "application/xz"; run = "ouch"; }
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

      keymap = {
        manager.prepend_keymap =
          [
            {
              on = [ "c" "Z" ];
              run = [ "plugin ouch --args=zip" ];
              desc = "Zip the selected files";
            }
            {
              on = [ "g" "r" ];
              run = ''shell 'ya pub dds-cd --str "$(git rev-parse --show-toplevel)"' --confirm'';
              desc = "Cd to root of current Git repo";
            }
          ]
          ++ lib.flatten (
            lib.mapAttrsToList (keys: loc: [
              {
                on = [ "g" ] ++ lib.stringToCharacters keys;
                run = "cd ${loc}";
                desc = "cd to ${loc}";
              }
              {
                on = [ "t" ] ++ lib.stringToCharacters keys;
                run = "tab_create ${loc}";
                desc = "open new tab to ${loc}";
              }
              {
                on = [ "m" ] ++ lib.stringToCharacters keys;
                run = [ "yank --cut" "escape --visual --select" loc ];
                desc = "move selection to ${loc}";
              }
              {
                on = [ "Y" ] ++ lib.stringToCharacters keys;
                run = [ "yank" "escape --visual --select" loc ];
                desc = "copy selection to ${loc}";
              }
            ]) shortcuts
          )
          ++ [
            {
              on = [ "t" "t" ];
              run = "tab_create";
              desc = "open new tab in current directory";
            }
          ];
      };
    };
  }

  # Desktop entry and MIME associations
  {
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
]
