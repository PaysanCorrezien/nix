#!/bin/sh

# Detect network interfaces
interfaces=$(ls /sys/class/net)
ethernet_connected=false

# Check for Ethernet connection
for interface in $interfaces; do
	if [ "$(cat /sys/class/net/$interface/type)" -eq 1 ]; then
		if [ "$(cat /sys/class/net/$interface/operstate)" = "up" ]; then
			ethernet_connected=true
			break
		fi
	fi
done

if $ethernet_connected; then
	echo "Ethernet connection detected."
else
	echo "No Ethernet connection detected."

	# Detect Wi-Fi interfaces
	wifi_interface=""
	for interface in $interfaces; do
		if [ "$(cat /sys/class/net/$interface/type)" -eq 1 ]; then
			if iw dev $interface info >/dev/null 2>&1; then
				wifi_interface=$interface
				break
			fi
		fi
	done

	if [ -z "$wifi_interface" ]; then
		echo "No Wi-Fi interface detected."
		exit 1
	else
		echo "Wi-Fi interface detected: $wifi_interface"
		read -p "Enter SSID: " ssid
		read -sp "Enter Wi-Fi password: " password
		echo

		# Create wpa_supplicant configuration
		wpa_passphrase "$ssid" "$password" >/tmp/wpa_supplicant.conf

		# Start wpa_supplicant
		sudo wpa_supplicant -B -i "$wifi_interface" -c /tmp/wpa_supplicant.conf

		# Obtain an IP address
		sudo dhclient "$wifi_interface"

		# Verify connection
		if ! ping -c 4 google.com >/dev/null 2>&1; then
			echo "Failed to connect to Wi-Fi."
			exit 1
		fi
	fi

