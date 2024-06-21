{inputs,lib, config, pkgs,sops-nix, ... }:

# TODO: sops url + name 
# prompt for creds on install or launch the CLI
# force sync with cmd or 
# dont use readfile and make it work more directly
 # Import the sops module to ensure it can be used here

# Import the sops module to ensure it can be used here
let
  # NOTE: workaround because Home Manager doesn't seem to be able to read config.sops.secrets.nextcloudUrl if defined by global module?
  nextcloudUrl = builtins.readFile "/run/secrets/nextcloudUrl";
  nextcloudUser = builtins.readFile "/run/secrets/nextcloudUser";
  passwordLocalPath = "${config.home.homeDirectory}/Documents/Password";
  passwordRemotePath = "/Password";
  musicLocalPath = "${config.home.homeDirectory}/Documents/Music";
  musicRemotePath = "/Musique";
  nextcloudConfig = ''
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
    0\\Folders\\1\\localPath=${passwordLocalPath}/
    0\\Folders\\1\\targetPath=${passwordRemotePath}
    0\\Folders\\1\\paused=false
    0\\Folders\\1\\ignoreHiddenFiles=false
    0\\Folders\\1\\virtualFilesMode=off
    0\\Folders\\1\\version=2
    0\\Folders\\2\\localPath=${musicLocalPath}/
    0\\Folders\\2\\targetPath=${musicRemotePath}
    0\\Folders\\2\\paused=false
    0\\Folders\\2\\ignoreHiddenFiles=false
    0\\Folders\\2\\virtualFilesMode=off
    0\\Folders\\2\\version=2
  '';
in {
  home.packages = with pkgs; [
    nextcloud-client
  ];

  home.activation.copyNextcloudConfig = lib.mkAfter ''
    mkdir -p /home/dylan/.config/Nextcloud
    echo "${nextcloudConfig}" > /home/dylan/.config/Nextcloud/nextcloud.cfg
    chown dylan:users /home/dylan/.config/Nextcloud/nextcloud.cfg
    chmod 644 /home/dylan/.config/Nextcloud/nextcloud.cfg

    # Create local sync folders if they don't exist
    mkdir -p ${passwordLocalPath}
    mkdir -p ${musicLocalPath}
  '';
}



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
