#!/bin/bash
# Simple Wazuh Agent Installer for Debian/Ubuntu

# Exit on errors
set -e

# Check parameters
if [ -z "$WAZUH_MANAGER" ] || [ -z "$WAZUH_REGISTRATION_PASSWORD" ]; then
  echo "Error: Missing required environment variables"
  echo "Usage: WAZUH_MANAGER=x.x.x.x WAZUH_REGISTRATION_PASSWORD=xxx WAZUH_AGENT_NAME=hostname $0"
  exit 1
fi

# Check if running as root/sudo
if [ "$(id -u)" -ne 0 ]; then
  echo "Error: This script must be run with sudo"
  exit 1
fi

# Set agent name to hostname if not provided
if [ -z "$WAZUH_AGENT_NAME" ]; then
  WAZUH_AGENT_NAME=$(hostname)
  echo "Notice: WAZUH_AGENT_NAME not set, using hostname: $WAZUH_AGENT_NAME"
fi

WAZUH_VERSION="4.11.1"
DEB_FILE="wazuh-agent_${WAZUH_VERSION}-1_amd64.deb"
DEB_URL="https://packages.wazuh.com/4.x/apt/pool/main/w/wazuh-agent/${DEB_FILE}"

# Download Wazuh agent package
echo "Downloading Wazuh agent ${WAZUH_VERSION}..."
if ! wget -q --show-progress "$DEB_URL"; then
  echo "Error: Failed to download Wazuh agent package"
  exit 1
fi

# Install package
echo "Installing Wazuh agent..."
dpkg -i "./${DEB_FILE}"

# Start and enable service
echo "Configuring Wazuh agent service..."
systemctl daemon-reload
systemctl enable wazuh-agent
systemctl start wazuh-agent

# Check service status
echo "Checking Wazuh agent service status..."
if systemctl is-active --quiet wazuh-agent; then
  echo "✓ Wazuh agent is running"
else
  echo "Warning: Wazuh agent service is not running. Check logs with: sudo systemctl status wazuh-agent"
fi

# Clean up
rm -f "./${DEB_FILE}"

echo "Wazuh agent installation completed"
echo "Manager: $WAZUH_MANAGER"
echo "Agent name: $WAZUH_AGENT_NAME"

exit 0