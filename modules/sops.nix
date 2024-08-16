{ lib, inputs, config, pkgs, ... }:

let
  cfg =
    config.settings.isServer; # assuming this is where your isServer boolean is set
in {
  environment.systemPackages = with pkgs; [ sops age ];

  imports = [ inputs.sops-nix.nixosModules.sops ];

  sops = lib.mkIf (!cfg) {
    defaultSopsFile = ./sops/kumo.yaml;
    defaultSopsFormat = "yaml";
    age.keyFile = "/home/dylan/.config/sops/age/keys.txt";
    secrets = {
      "nextcloudUrl" = { owner = "dylan"; };
      "nextcloudUser" = { owner = "dylan"; };
      "nextcloudKey" = { };
      "wifi_homekey" = { owner = "dylan"; };
      "tailscale_auth_key" = { owner = "dylan"; };
      # New Thunderbird secrets
      "thunderbird/account1/name" = { owner = "dylan"; };
      "thunderbird/account1/email" = { owner = "dylan"; };
      "thunderbird/account1/server" = { owner = "dylan"; };
      "thunderbird/account1/port" = { owner = "dylan"; };
      "thunderbird/account1/username" = { owner = "dylan"; };
      # # "thunderbird.account1.password" = { owner = "dylan"; };
      "thunderbird/account2/name" = { owner = "dylan"; };
      "thunderbird/account2/email" = { owner = "dylan"; };
      "thunderbird/account2/server" = { owner = "dylan"; };
      "thunderbird/account2/port" = { owner = "dylan"; };
      "thunderbird/account2/username" = { owner = "dylan"; };
      # "thunderbird.account2.password" = { owner = "dylan"; };
      # Add more accounts as needed
    };
  };
}

