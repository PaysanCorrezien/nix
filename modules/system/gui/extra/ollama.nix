{ config, pkgs, lib, ... }:
let cfg = config.settings.ai.server.enable;
in {
  config = lib.mkIf (cfg) {
    # services.ollama = {
    #   enable = true;
    #   home = "/var/lib/ollama";
    #   # /var/lib/ollama/models
    #   models = "\${config.services.ollama.home}/models";
    #
    #   openFirewall = true;
    #   loadModels = [ "llama3.1" "phi3" ];
    #   acceleration = "cuda"; # Enable CUDA acceleration for NVIDIA GPUs
    #   host =
    #     "0.0.0.0"; # Listen on all interfaces (be cautious with this setting)
    # };
    # Configure the user 'dylan'
    users.users.dylan = {
      extraGroups = [
        "docker"
      ]; # Add to wheel group for sudo and docker group for Docker access
    };

    # Enable Docker with NVIDIA runtime
    virtualisation.docker = {
      enable = true;
      enableOnBoot = true;
      # enableNvidia = true; # Enable NVIDIA runtime for Docker
      daemon.settings = {
        data-root = "/var/lib/docker"; # Change this path as needed
      };
      extraOptions = ''
        {
          "default-runtime": "nvidia",
          "runtimes": {
            "nvidia": {
              "path": "nvidia-container-runtime",
              "runtimeArgs": []
            }
          }
        }
      '';
    };
    # Add CUDA and cuDNN for AI workloads
    environment.systemPackages = with pkgs; [
      docker
      docker-compose
      lazydocker
    ];
  };
}
