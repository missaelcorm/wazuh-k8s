#!/bin/bash
# Simple Wazuh Agent Installer for macOS

# Exit on errors
set -e

# Check parameters
if [ $# -lt 4 ]; then
  echo "Error: Missing required parameters"
  echo "Usage: $0 <WAZUH_MANAGER> <WAZUH_REGISTRATION_SERVER> <WAZUH_REGISTRATION_PASSWORD> <WAZUH_PACKAGE>"
  exit 1
fi

# Check if running as root/sudo
if [ "$(id -u)" -ne 0 ]; then
  echo "Error: This script must be run with sudo"
  exit 1
fi

WAZUH_MANAGER="$1"
WAZUH_REGISTRATION_SERVER="$2"
WAZUH_REGISTRATION_PASSWORD="$3"
WAZUH_PACKAGE="$4"

# Check if package exists
if [ ! -f "$WAZUH_PACKAGE" ]; then
  echo "Error: Package not found: $WAZUH_PACKAGE"
  exit 1
fi

# Create environment file with secure permissions
ENV_FILE="/tmp/wazuh_envs"
echo "WAZUH_MANAGER='$WAZUH_MANAGER'" > "$ENV_FILE"
echo "WAZUH_REGISTRATION_SERVER='$WAZUH_REGISTRATION_SERVER'" >> "$ENV_FILE"
echo "WAZUH_REGISTRATION_PASSWORD='$WAZUH_REGISTRATION_PASSWORD'" >> "$ENV_FILE"
chmod 600 "$ENV_FILE"

# Install package (installer will read from /tmp/wazuh_envs)
echo "Installing Wazuh agent..."
installer -pkg "$WAZUH_PACKAGE" -target /

# Start agent
echo "Starting Wazuh agent..."
launchctl load /Library/LaunchDaemons/com.wazuh.agent.plist

# Clean up
rm -f "$ENV_FILE"

echo "Wazuh agent installation completed"
echo "Manager: $WAZUH_MANAGER"

exit 0