# VMware NixOS Install

## Requirements
- VMware set to **UEFI mode** (Settings → Options → Advanced → Firmware: UEFI)
- Minimum 4GB RAM recommended

## Install

```bash
# Boot NixOS live ISO, then:
sudo -i
curl -L https://raw.githubusercontent.com/paysancorrezien/nix/main/setup.sh | bash
```

Select `vmware-minimal` for bootstrap, or `vmware` for full config.

## Post-Install

```bash
# Fix flake ownership
sudo chown -R dylan:dylan ~/.config/nix

# Upgrade to full config (if installed minimal)
sudo nixos-rebuild switch --flake ~/.config/nix#vmware
```

## Default Credentials
- User: `dylan`
- Password: `dylan`

## Notes
- Disk: `/dev/sda` (standard VMware SCSI)
- SSH disabled by default on vmware-minimal
- Replace `hosts/keys/vmware.pub` with real SSH key if enabling SSH
