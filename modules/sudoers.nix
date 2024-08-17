{ config, pkgs, lib, ... }:

let settings = config.settings;
in {
  config = lib.mkIf settings.autoSudo {
    security.sudo.extraRules = [{
      users = [ "dylan" ];
      commands = [{
        command = "ALL";
        options = [ "NOPASSWD" ];
      }];
    }];

    home-manager.sharedModules = [{
      systemd.user.services.home-manager-dylan = {
        Unit = { Description = "Home Manager for user dylan"; };
        Install = { WantedBy = [ "default.target" ]; };
        Service = {
          Type = "oneshot";
          RemainAfterExit = true;
          ExecStart = "${pkgs.home-manager}/bin/home-manager switch";
        };
      };
    }];

    security.polkit.extraConfig = ''
      polkit.addRule(function(action, subject) {
        if (action.id.indexOf("org.freedesktop.systemd1.manage-units") == 0 &&
            action.lookup("unit") == "home-manager-dylan.service" &&
            subject.user == "dylan") {
          return polkit.Result.YES;
        }
      });
    '';
  };
}
