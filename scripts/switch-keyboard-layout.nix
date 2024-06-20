# scripts/switch-keyboard-layout.nix
{ pkgs }:

pkgs.writeScriptBin "switch-keyboard-layout" ''
  current_layout=$(setxkbmap -query | grep layout | awk '{print $2}')

  if [ "$current_layout" = "fr" ]; then
    setxkbmap us -variant altgr-intl -option nodeadkeys
    echo "Switched to US (altgr-intl, nodeadkeys) layout"
  else
    setxkbmap fr
    echo "Switched to French (AZERTY) layout"
  fi
''

