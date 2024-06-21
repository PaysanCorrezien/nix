{inputs, config, pkgs,sops-nix, ... }:

# TODO: sops url + name 
# prompt for creds on install or launch the CLI
# force sync with cmd or 
# dont use readfile and make it work more directly
 # Import the sops module to ensure it can be used here

# Import the sops module to ensure it can be used here
let
  # sopsModule = inputs.sops-nix.homeManagerModules.sops;
  # nextcloudUrl = builtins.readFile "${config.sops.secrets.nextcloudUrl.path}";
  # nextcloudUser = builtins.readFile "${config.sops.secrets.nextcloudUser.path}";
# NOTE: workarounb becase home manager dont seems to be able to read config.sops.secrets.nextcloudUrl if defined by global module ?
    nextcloudUrl = builtins.readFile "/run/secrets/nextcloudUrl";
  nextcloudUser = builtins.readFile "/run/secrets/nextcloudUser";
in {
  # Import the sops module to ensure it can be used here
  # imports = [ sopsModule ];

  home.packages = with pkgs; [
    nextcloud-client
  ];


  home.file.".config/Nextcloud/nextcloud.cfg".text = ''
  [General]
  startInBackground=true
  showInExplorerNavigationPane=true

  [Accounts]
  version=2
  0\\version=1
  0\\url=${nextcloudUrl}
  0\\dav_user=${nextcloudUser}
  0\\webflow_user=${nextcloudUser}
  0\\authType=webflow
  0\\user=@Invalid()
  0\\Folders\\1\\localPath=$HOME/Documents/Password/
  0\\Folders\\1\\targetPath=/Password
  0\\Folders\\1\\paused=false
  0\\Folders\\1\\ignoreHiddenFiles=false
  0\\Folders\\1\\virtualFilesMode=off
  0\\Folders\\1\\version=2
  0\\Folders\\2\\localPath=$HOME/Documents/Music/
  0\\Folders\\2\\targetPath=/Musique
  0\\Folders\\2\\paused=false
  0\\Folders\\2\\ignoreHiddenFiles=false
  0\\Folders\\2\\virtualFilesMode=off
  0\\Folders\\2\\version=2
  '';

  # The systemd service and timer definitions can be uncommented and adjusted as needed
  # systemd.user.services.nextcloud-autosync = {
  #   Unit = {
  #     Description = "Auto sync Nextcloud";
  #     After = "network-online.target"; 
  #   };
  #   Service = {
  #     Type = "simple";
  #     Environment = "nextcloud_key=${nextcloudKey} nextcloud_url=${nextcloudUrl} nextcloud_user=${nextcloudUser}";
  #     ExecStart = "${pkgs.nextcloud-client}/bin/nextcloudcmd -h -n --user ${nextcloudUser} --password ${nextcloudKey} --path $HOME/Documents/Music/ ${nextcloudUrl}/remote.php/webdav/Musique && ${pkgs.nextcloud-client}/bin/nextcloudcmd -h -n --user ${nextcloudUser} --password ${nextcloudKey} --path $HOME/Documents/Password/ ${nextcloudUrl}/remote.php/webdav/Password";
  #     TimeoutStopSec = "180";
  #     KillMode = "process";
  #     KillSignal = "SIGINT";
  #   };
  #   Install.WantedBy = ["multi-user.target"];
  # };

  # systemd.user.timers.nextcloud-autosync = {
  #   Unit.Description = "Automatic sync files with Nextcloud every hour";
  #   Timer.OnBootSec = "5min";
  #   Timer.OnUnitActiveSec = "60min";
  #   Install.WantedBy = ["multi-user.target" "timers.target"];
  # };

  # systemd.user.startServices = true;
}
