# system-virtualization.nix
{
  config,
  pkgs,
  lib,
  ...
}:
let
  cfg = config.settings.virtualisation.enable;
  vmName = "windows-11";
  vmPath = "/home/dylan/Documents/vm";
  workspace = "12";
  launchScript = pkgs.writeShellScriptBin "launch-windows-vm" ''
    # Function to get current workspace
    get_current_workspace() {
      ${pkgs.xdotool}/bin/xdotool get_desktop
    }

    # Function to switch to workspace
    switch_to_workspace() {
      ${pkgs.xdotool}/bin/xdotool set_desktop $1
    }

    # Function to save current workspace
    save_current_workspace() {
      get_current_workspace > "$PREV_WORKSPACE_FILE"
    }

    # Save current workspace before launching VM
    save_current_workspace

    # Launch the VM
    ${pkgs.quickemu}/bin/quickemu --vm ${vmPath}/${vmName}.conf --display spice &

    # Wait for the Spicy window to appear
    while ! window_id=$(${pkgs.wmctrl}/bin/wmctrl -l | grep -i "spicy" | awk '{print $1}'); do
      sleep 1
    done

    # Move the window to workspace ${workspace} (index $((${workspace} - 1)) because wmctrl uses 0-based indexing)
    ${pkgs.wmctrl}/bin/wmctrl -i -r $window_id -t $((${workspace} - 1))

    # Switch to the VM's workspace
    switch_to_workspace $((${workspace} - 1))

    # Focus the VM window
    ${pkgs.xdotool}/bin/xdotool search --name "spicy" windowactivate
  '';

  toggleScript = pkgs.writeShellScriptBin "toggle-windows-vm" ''
    WORKSPACE="${workspace}"
    PREV_WORKSPACE_FILE="/tmp/prev_workspace"

    # Function to check if VM is running
    is_vm_running() {
      ${pkgs.wmctrl}/bin/wmctrl -l | grep -q "spicy"
    }

    # Function to get current workspace
    get_current_workspace() {
      ${pkgs.xdotool}/bin/xdotool get_desktop
    }

    # Function to switch to workspace
    switch_to_workspace() {
      ${pkgs.xdotool}/bin/xdotool set_desktop $1
    }

    # Function to save current workspace
    save_current_workspace() {
      get_current_workspace > "$PREV_WORKSPACE_FILE"
    }

    # Function to restore previous workspace
    restore_previous_workspace() {
      if [[ -f "$PREV_WORKSPACE_FILE" ]]; then
        switch_to_workspace $(cat "$PREV_WORKSPACE_FILE")
        rm "$PREV_WORKSPACE_FILE"
      fi
    }

    # Function to focus VM window
    focus_vm() {
      ${pkgs.wmctrl}/bin/wmctrl -a "spicy"
    }

    # Main logic
    CURRENT_WORKSPACE=$(get_current_workspace)
    if [[ $CURRENT_WORKSPACE -eq $((WORKSPACE - 1)) ]]; then
      # We're on the VM workspace, go back to previous workspace
      restore_previous_workspace
    else
      # We're not on the VM workspace
      if is_vm_running; then
        # VM is running, switch to its workspace
        save_current_workspace
        switch_to_workspace $((WORKSPACE - 1))
        focus_vm
      else
        # VM is not running, just switch to its workspace
        save_current_workspace
        switch_to_workspace $((WORKSPACE - 1))
      fi
    fi
  '';
in
# TODO: make it so it genrates the config file for the VMs
{
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

    users.users.dylan.extraGroups = [
      "libvirtd"
      "kvm"
    ];

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
      quickemu
      # quickgui
      samba
      wmctrl
      launchScript
    ];

    # Generate .desktop file for the VM
    home-manager.users.dylan =
      { pkgs, ... }:
      {
        home.packages = [ pkgs.qemu ];

        xdg.desktopEntries.${vmName} = {
          name = vmName;
          exec = "${launchScript}/bin/launch-windows-vm";
          icon = "qemu";
          type = "Application";
          terminal = false;
        };
      };
    # Enable CPU virtualization extensions (AMD-specific)
    boot.kernelModules = [ "kvm-amd" ];
    boot.extraModprobeConfig = "options kvm_amd nested=1"; # Enable nested virtualization for AMD

    # Enable IOMMU for potential GPU passthrough
    boot.kernelParams = [
      "amd_iommu=on"
      "iommu=pt"
    ];

    # Set up libvirt storage pool using extraConfig
    # virtualisation.libvirtd.extraConfig = ''
    #   unix_sock_group = "libvirtd"
    #   unix_sock_rw_perms = "0770"
    #   log_filters="3:qemu 3:libvirt 3:conf 3:security 3:event 3:file 3:object 1:*"
    #   log_outputs="3:syslog:virtlogd"
    # '';

    # Ensure libvirt storage pool is set up
    # systemd.services.libvirt-storage-setup = {
    #   description = "LibVirt Storage Pool Setup";
    #   after = [ "libvirtd.service" ];
    #   wantedBy = [ "multi-user.target" ];
    #   serviceConfig = {
    #     Type = "oneshot";
    #     RemainAfterExit = true;
    #   };
    #   script = ''
    #     # Check if the pool already exists
    #     if ! ${pkgs.libvirt}/bin/virsh pool-info default >/dev/null 3>&1; then
    #       ${pkgs.libvirt}/bin/virsh pool-define-as --name default --type dir --target /var/lib/libvirt/images
    #       ${pkgs.libvirt}/bin/virsh pool-autostart default
    #       ${pkgs.libvirt}/bin/virsh pool-start default
    #     fi
    #   '';
    # };
  };
}
