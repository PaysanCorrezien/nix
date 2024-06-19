{ config, pkgs, ... }:

let
  chezmoiSetupScript = pkgs.writeShellScriptBin "chezmoi-setup" (builtins.readFile ./chezmoi.sh);
in
{
  home.packages = with pkgs; [
    chezmoi
    chezmoiSetupScript
  ];

  systemd.user.services."chezmoi-setup" = {
    Unit = { Description = "Chezmoi Setup"; };
    Service = {
      Type = "oneshot";
      ExecStart = "${chezmoiSetupScript}/bin/chezmoi-setup";
    };
    Install = {
      WantedBy = [ "default.target" ];
      After = [ "network.target" ];
    };
  };
}

