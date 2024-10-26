{ lib, pkgs, config, ... }:
#FIX: make the multi file yank work , neither dragon / xckip or clipboard-jh work
#TODO: mvove all this whe na plugin management for nix is realy availabe
#TODO: create a vrapper that :
# take an array of plugins name and github repo, and install them if the pack dont exit, then run ya pack -u 
# make each pack have an init.lu option and keymap option ?
# HACK: some plugins are not installed by this like the copy one
let
  mkYaziPlugin = name: text: {
    "${name}" = toString (pkgs.writeTextDir "${name}.yazi/init.lua" text) + "/${name}.yazi";
  };

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
      ouch
      xdragon
      zoxide
      ueberzugpp
      unar
      exiftool
      clipboard-jh # https://github.com/Slackadays/ClipBoard
      trash-cli
    ];

    programs.yazi = {
      enable = true;
      enableZshIntegration = true;

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
      '';


      settings = {
        manager = {
          show_hidden = true;
          sort_by = "modified";
          sort_dir_first = true;
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

#HACK: this plugin is not installed by nix :
        previewers = {
          prepend = [
            { mime = "application/*zip"; run = "ouch"; }
            { mime = "application/x-tar"; run = "ouch"; }
            { mime = "application/x-bzip2"; run = "ouch"; }
            { mime = "application/x-7z-compressed"; run = "ouch"; }
            { mime = "application/x-rar"; run = "ouch"; }
            { mime = "application/x-xz"; run = "ouch"; }
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
            # Open Dragon with current selection
            {
              on = "<C-n>";
              run = ''shell 'dragon -x -i -T "$1"' --confirm'';
              desc = "Open dragon with current selection";
            }

            # Yank and copy to clipboard for X11
            {
              on = "y";
              run = [
                ''shell 'URIS=""; for path in "$@"; do URIS="$URIS\nfile://$(realpath "$path")"; done; echo -e "$URIS" | xclip -i -selection clipboard -t text/uri-list' --confirm''
                "yank"
              ];
              desc = "Yank and copy to clipboard (X11)";
            }
            #HACK: this plugin is not installed by nix : https://github.com/AnirudhG07/plugins-yazi/tree/main/copy-file-contents.yazi
            {
              on = [ "c" "C" ];
              run = [ "plugin copy-file-contents" ];
              desc = "Copy contents of file";
            }
            #HACK: this plugin is not installed by nix : https://github.com/ndtoan96/ouch.yazi
            # ya pack -a ndtoan96/ouch                                                                                                                                                                              
            {
              on = [ "c" "Z" ];
              run = [ "plugin ouch --args=zip" ];
              desc = "Zip the selected files";
            }
            # Yank and copy to clipboard for Wayland
            # NOTE: check for this
            # {
            #   on = "y";
            #   run = [
            #     ''shell 'for path in "$@"; do echo "file://$path"; done | wl-copy -t text/uri-list' --confirm''
            #     "yank"
            #   ];
            #   desc = "Yank and copy to clipboard (Wayland)";
            # }

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
            lib.mapAttrsToList
              (keys: loc: [
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
              ])
              shortcuts
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
            #
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

    home.shellAliases = {
      y = "yazi";
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
  # https://github.com/yazi-rs/plugins/tree/main/max-preview.yazi
  {
    programs.yazi = {
      plugins = mkYaziPlugin "max-preview" ''
        local function entry(st)
            if st.old then
                Tab.layout, st.old = st.old, nil
            else
                st.old = Tab.layout
                Tab.layout = function(self)
                    self._chunks = ui.Layout()
                        :direction(ui.Layout.HORIZONTAL)
                        :constraints({
                            ui.Constraint.Percentage(0),
                            ui.Constraint.Percentage(0),
                            ui.Constraint.Percentage(100),
                        })
                        :split(self._area)
                end
            end
            ya.app_emit("resize", {})
        end

        local function enabled(st) return st.old ~= nil end

        return { entry = entry, enabled = enabled }
      '';
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
      plugins = mkYaziPlugin "system-clipboard" ''
                      -- Meant to run at async context. (yazi system-clipboard)

        local selected_or_hovered = ya.sync(function()
        	local tab, paths = cx.active, {}
        	for _, u in pairs(tab.selected) do
        		paths[#paths + 1] = tostring(u)
        	end
        	if #paths == 0 and tab.current.hovered then
        		paths[1] = tostring(tab.current.hovered.url)
        	end
        	return paths
        end)

        return {
        	entry = function()
        		ya.manager_emit("escape", { visual = true })

        		local urls = selected_or_hovered()

        		if #urls == 0 then
        			return ya.notify({ title = "System Clipboard", content = "No file selected", level = "warn", timeout = 5 })
        		end

        		-- ya.notify({ title = #urls, content = table.concat(urls, " "), level = "info", timeout = 5 })

        		local status, err =
        				Command("cb")
        				:arg("copy")
        				:args(urls)
        				:spawn()
        				:wait()

        		if status or status.succes then
        			ya.notify({
        				title = "System Clipboard",
        				content = "Succesfully copied the file(s) to system clipboard",
        				level = "info",
        				timeout = 5,
        			})
        		end

        		if not status or not status.success then
        			ya.notify({
        				title = "System Clipboard",
        				content = string.format(
        					"Could not copy selected file(s) %s",
        					status and status.code or err
        				),
        				level = "error",
        				timeout = 5,
        			})
        		end
        	end,
        }
      '';
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
      plugins = mkYaziPlugin "chmod" ''
              local selected_or_hovered = ya.sync(function()
        	local tab, paths = cx.active, {}
        	for _, u in pairs(tab.selected) do
        		paths[#paths + 1] = tostring(u)
        	end
        	if #paths == 0 and tab.current.hovered then
        		paths[1] = tostring(tab.current.hovered.url)
        	end
        	return paths
        end)

        return {
        	entry = function()
        		ya.manager_emit("escape", { visual = true })

        		local urls = selected_or_hovered()
        		if #urls == 0 then
        			return ya.notify { title = "Chmod", content = "No file selected", level = "warn", timeout = 5 }
        		end

        		local value, event = ya.input {
        			title = "Chmod:",
        			position = { "top-center", y = 3, w = 40 },
        		}
        		if event ~= 1 then
        			return
        		end

        		local status, err = Command("chmod"):arg(value):args(urls):spawn():wait()
        		if not status or not status.success then
        			ya.notify {
        				title = "Chmod",
        				content = string.format("Chmod with selected files failed, exit code %s", status and status.code or err),
        				level = "error",
        				timeout = 5,
        			}
        		end
        	end,
        }

      '';
      keymap.manager.prepend_keymap = [
        {
          on = [ "c" "m" ];
          run = "plugin chmod";
          desc = "Chmod on selected files";
        }
      ];
    };
  }

  {
    programs.yazi = {
      # https://github.com/yazi-rs/plugins/tree/main/full-border.yazi
      plugins = mkYaziPlugin "full-border" ''
            -- TODO: remove this once v0.4 is released
        local v4 = function(typ, area, ...)
        	if typ == "bar" then
        		return ui.Table and ui.Bar(...):area(area) or ui.Bar(area, ...)
        	else
        		return ui.Table and ui.Border(...):area(area) or ui.Border(area, ...)
        	end
        end

        local function setup(_, opts)
        	local type = opts and opts.type or ui.Border.ROUNDED
        	local old_build = Tab.build

        	Tab.build = function(self, ...)
        		local bar = function(c, x, y)
        			if x <= 0 or x == self._area.w - 1 then
        				return v4("bar", ui.Rect.default, ui.Bar.TOP)
        			end

        			return v4(
        				"bar",
        				ui.Rect { x = x, y = math.max(0, y), w = ya.clamp(0, self._area.w - x, 1), h = math.min(1, self._area.h) },
        				ui.Bar.TOP
        			):symbol(c)
        		end

        		local c = self._chunks
        		self._chunks = {
        			c[1]:padding(ui.Padding.y(1)),
        			c[2]:padding(ui.Padding(c[1].w > 0 and 0 or 1, c[3].w > 0 and 0 or 1, 1, 1)),
        			c[3]:padding(ui.Padding.y(1)),
        		}

        		local style = THEME.manager.border_style
        		self._base = ya.list_merge(self._base or {}, {
        			v4("border", self._area, ui.Border.ALL):type(type):style(style),
        			v4("bar", self._chunks[1], ui.Bar.RIGHT):style(style),
        			v4("bar", self._chunks[3], ui.Bar.LEFT):style(style),

        			bar("┬", c[1].right - 1, c[1].y),
        			bar("┴", c[1].right - 1, c[1].bottom - 1),
        			bar("┬", c[2].right, c[2].y),
        			bar("┴", c[2].right, c[2].bottom - 1),
        		})

        		old_build(self, ...)
        	end
        end

        return { setup = setup }

      '';
      keymap.manager.prepend_keymap = [
        {
          on = "T";
          run = "plugin --sync max-preview";
          desc = "Maximize or restore preview";
        }
      ];
    };
  }
]

