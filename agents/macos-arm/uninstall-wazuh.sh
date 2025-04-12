#!/bin/bash
# Simple Wazuh Agent Uninstaller for macOS

# Exit on errors
set -e

# Check if running as root/sudo
if [ "$(id -u)" -ne 0 ]; then
  echo "Error: This script must be run with sudo"
  exit 1
fi

echo "Uninstalling Wazuh agent..."

# Stop the agent service
echo "Stopping Wazuh agent service..."
if launchctl list | grep -q com.wazuh.agent; then
  launchctl unload /Library/LaunchDaemons/com.wazuh.agent.plist
  echo "✓ Service stopped"
else
  echo "Service was not running"
fi

# Remove files and directories
echo "Removing Wazuh files..."
[ -d "/Library/Ossec" ] && rm -r /Library/Ossec
[ -f "/Library/LaunchDaemons/com.wazuh.agent.plist" ] && rm -f /Library/LaunchDaemons/com.wazuh.agent.plist
[ -d "/Library/StartupItems/WAZUH" ] && rm -rf /Library/StartupItems/WAZUH

# Remove user and group
echo "Removing Wazuh user and group..."
dscl . -list /Users | grep -q "^wazuh$" && dscl . -delete "/Users/wazuh"
dscl . -list /Groups | grep -q "^wazuh$" && dscl . -delete "/Groups/wazuh"

# Remove package receipt
echo "Removing package receipt..."
pkgutil --pkg-info com.wazuh.pkg.wazuh-agent >/dev/null 2>&1 && pkgutil --forget com.wazuh.pkg.wazuh-agent

echo "Wazuh agent has been successfully uninstalled"
exit 0