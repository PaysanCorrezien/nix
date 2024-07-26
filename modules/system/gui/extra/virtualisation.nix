# system-virtualization.nix
{ config, pkgs, lib, ... }:
let
  cfg = config.settings.virtualisation.enable;

  # TODO: make it so it genrates the config file for the VMs
in {
  config = lib.mkIf cfg {
    # Enable QEMU/KVM virtualization
    virtualisation.libvirtd = {
      enable = true;
      qemu = {
        runAsRoot = false;
        ovmf.enable = true;
        swtpm.enable = true;
      };
      onBoot = "ignore";
      onShutdown = "shutdown";
    };

    virtualisation.spiceUSBRedirection.enable = true;

    users.users.dylan.extraGroups = [ "libvirtd" "kvm" ];

    security.polkit.enable = true;

    # Install necessary packages
    environment.systemPackages = with pkgs; [
      virt-manager
      qemu
      OVMF
      spice-gtk
      win-virtio
      pciutils
      looking-glass-client # For GPU passthrough
    ];

    # Enable CPU virtualization extensions (AMD-specific)
    boot.kernelModules = [ "kvm-amd" ];
    boot.extraModprobeConfig =
      "options kvm_amd nested=1"; # Enable nested virtualization for AMD

    # Enable IOMMU for potential GPU passthrough
    boot.kernelParams = [ "amd_iommu=on" "iommu=pt" ];

    # Set up libvirt storage pool using extraConfig
    virtualisation.libvirtd.extraConfig = ''
      unix_sock_group = "libvirtd"
      unix_sock_rw_perms = "0770"
      log_filters="3:qemu 3:libvirt 3:conf 3:security 3:event 3:file 3:object 1:*"
      log_outputs="3:syslog:virtlogd"
    '';

    # Ensure libvirt storage pool is set up
    systemd.services.libvirt-storage-setup = {
      description = "LibVirt Storage Pool Setup";
      after = [ "libvirtd.service" ];
      wantedBy = [ "multi-user.target" ];
      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
      };
      script = ''
        # Check if the pool already exists
        if ! ${pkgs.libvirt}/bin/virsh pool-info default >/dev/null 2>&1; then
          ${pkgs.libvirt}/bin/virsh pool-define-as --name default --type dir --target /var/lib/libvirt/images
          ${pkgs.libvirt}/bin/virsh pool-autostart default
          ${pkgs.libvirt}/bin/virsh pool-start default
        fi
      '';
    };
  };
}
