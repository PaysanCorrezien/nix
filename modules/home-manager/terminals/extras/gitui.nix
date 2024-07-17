{ pkgs, lib, settings, ... }:
let cfg = settings.terminal.extras;
in {
  config = lib.mkIf cfg.enable {
    programs.gitui = {
      enable = true;
      keyConfig = ''
        (
          move_left: Some(( code: Char('h'), modifiers: "")),
          move_right: Some(( code: Char('l'), modifiers: "")),
          move_up: Some(( code: Char('k'), modifiers: "")),
          move_down: Some(( code: Char('j'), modifiers: "")),
          stash_open: Some(( code: Char('l'), modifiers: "")),
          open_help: Some(( code: Char('?'), modifiers: "")),
          status_reset_item: Some(( code: Char('U'), modifiers: "SHIFT")),
          )
      '';
    };
  };
}
