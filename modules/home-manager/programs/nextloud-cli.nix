# { inputs, lib, config, pkgs, sops-nix, ... }:

# TODO: sops url + name 
# prompt for creds on install or launch the CLI
# force sync with cmd or 
# dont use readfile and make it work more directly
# Import the sops module to ensure it can be used here

#FIXME: This is a workaround to ensure that the secrets are read from the correct location
# this doestn work on first init i need to find a better way to do this but 
# i cant make the sops.templates work passed from system nixosmodules as of now
{ config, pkgs, lib, ... }:

let
  readSecretFile = file:
    lib.optionalString (builtins.pathExists file) (builtins.readFile file);

  # NOTE: https://github.com/Mic92/sops-nix/issues/498
  nextcloudUrl = readSecretFile "/run/secrets/nextcloudUrl";
  nextcloudUser = readSecretFile "/run/secrets/nextcloudUser";
  passwordLocalPath = "${config.home.homeDirectory}/Documents/Password";
  passwordRemotePath = "/Password";
  wallpaperLocalPath = "${config.home.homeDirectory}/Images/Wallpaper";
  wallpaperRemotePath = "/Configuration/wallpaper";
  musicLocalPath = "${config.home.homeDirectory}/Documents/Music";
  musicRemotePath = "/Musique";
  projetLocalPath = "${config.home.homeDirectory}/Documents/Projets";
  projetRemotePath = "/Work/Projet";
  nextcloudExclude = builtins.readFile ./nextcloud_exclude.txt;
  excludeFile =
    "${config.home.homeDirectory}/.config/Nextcloud/sync-exclude.lst";
  stateFile =
    "${config.home.homeDirectory}/.config/Nextcloud/.nextcloud_cfg_written";
  nextcloudLocal =
    "${config.home.homeDirectory}/.config/Nextcloud/nextcloud.cfg";
  nextcloudConfig = ''
    [General]
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
    0\\Folders\\3\\localPath=${wallpaperLocalPath}/
    0\\Folders\\3\\targetPath=${wallpaperRemotePath}
    0\\Folders\\3\\paused=false
    0\\Folders\\3\\ignoreHiddenFiles=false
    0\\Folders\\3\\virtualFilesMode=off
    0\\Folders\\3\\version=2
    0\\Folders\\4\\localPath=${projetLocalPath}/
    0\\Folders\\4\\targetPath=${projetRemotePath}
    0\\Folders\\4\\paused=false
    0\\Folders\\4\\ignoreHiddenFiles=false
    0\\Folders\\4\\virtualFilesMode=off
    0\\Folders\\4\\version=2
  '';

in
{
  options = {
    settings = lib.mkOption {
      type = lib.types.submodule {
        options.nextcloudcli = lib.mkOption {
          type = lib.types.submodule {
            options.enable =
              lib.mkEnableOption "Enable custom Nextcloud configuration";
          };
        };
      };
    };
  };

  config = lib.mkIf config.settings.nextcloudcli.enable {
    home.packages = with pkgs; [ nextcloud-client ];

    home.file."${excludeFile}".text = nextcloudExclude;

    home.activation.copyNextcloudConfig = lib.mkAfter ''
      if [ ! -f ${stateFile} ]; then
        echo "Creating Nextcloud config directory"
        mkdir -p "${config.home.homeDirectory}"/.config/Nextcloud
        echo "Writing config to ${nextcloudLocal}"
        echo "${nextcloudConfig}" > ${nextcloudLocal}
        chown ${config.home.username}:users ${nextcloudLocal}
        chmod 644 ${nextcloudLocal}
        # Create local sync folders if they don't exist
        echo "Creating local sync folders"
        mkdir -p ${passwordLocalPath}
        mkdir -p ${musicLocalPath}
        mkdir -p ${wallpaperLocalPath}
        mkdir -p ${projetLocalPath}
        # Create state file to indicate that the configuration has been written
        echo "Creating state file"
        touch ${stateFile}
      else
        echo "State file exists, skipping configuration"
      fi
    '';
  };
}
