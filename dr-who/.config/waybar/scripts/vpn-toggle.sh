#!/bin/bash

# Check if the VPN is active by looking for the network interface
if ip link show proton0 >/dev/null 2>&1; then
    # Use the official disconnect command
    protonvpn disconnect
    notify-send "TARDIS Shield" "Cloaking Device Deactivated" -i security-low
else
    # Use the official connect command (defaults to fastest automatically)
    notify-send "TARDIS Shield" "Activating Cloaking Device..." -i security-high
    protonvpn connect
fi
