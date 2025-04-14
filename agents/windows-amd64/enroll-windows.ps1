# Wazuh Agent Installation Script for Windows
# Run as Administrator

param (
    [Parameter(Mandatory=$true)]
    [string]$WazuhManager,
    
    [Parameter(Mandatory=$true)]
    [string]$RegistrationServer,
    
    [Parameter(Mandatory=$true)]
    [string]$RegistrationPassword,
    
    [Parameter(Mandatory=$false)]
    [string]$AgentName = $env:COMPUTERNAME,
    
    [Parameter(Mandatory=$false)]
    [string]$Version = "4.11.1"
)

# Check if running as Administrator
if (-NOT ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Error "This script must be run as Administrator"
    exit 1
}

$ErrorActionPreference = "Stop"

# Installer filename and URL
$msiFile = "wazuh-agent-$Version-1.msi"
$downloadUrl = "https://packages.wazuh.com/4.x/windows/$msiFile"
$downloadPath = "$env:TEMP\$msiFile"

# Download Wazuh agent
Write-Host "Downloading Wazuh agent $Version..."
try {
    Invoke-WebRequest -Uri $downloadUrl -OutFile $downloadPath
    Write-Host "Download completed"
} catch {
    Write-Error "Failed to download Wazuh agent: $_"
    exit 1
}

# Install Wazuh agent
Write-Host "Installing Wazuh agent..."
try {
    $arguments = "/q WAZUH_MANAGER=`"$WazuhManager`" WAZUH_REGISTRATION_SERVER=`"$RegistrationServer`" WAZUH_REGISTRATION_PASSWORD=`"$RegistrationPassword`" WAZUH_AGENT_NAME=`"$AgentName`""
    Start-Process -FilePath "msiexec.exe" -ArgumentList "/i `"$downloadPath`" $arguments" -Wait -NoNewWindow
    Write-Host "Installation completed"
} catch {
    Write-Error "Failed to install Wazuh agent: $_"
    exit 1
}

# Start Wazuh service
Write-Host "Starting Wazuh service..."
try {
    Start-Service -Name "Wazuh" -ErrorAction Stop
    Write-Host "Wazuh service started successfully"
} catch {
    Write-Error "Failed to start Wazuh service: $_"
    exit 1
}

# Verify service is running
$service = Get-Service -Name "Wazuh" -ErrorAction SilentlyContinue
if ($service -and $service.Status -eq "Running") {
    Write-Host "✓ Wazuh agent is running"
} else {
    Write-Warning "Wazuh agent service is not running. Check Windows Event Logs for details."
}

Write-Host "Wazuh agent installation completed"
Write-Host "Manager: $WazuhManager"
Write-Host "Agent name: $AgentName"