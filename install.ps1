#!/usr/bin/env pwsh

$fileUrl = "https://pkgs.netbird.io/windows/x64"
$fileDest = "$env:TEMP\netbird_installer.exe"

Invoke-WebRequest -Uri $fileUrl -OutFile $fileDest

Write-Host "Installer downloaded successfully..."

Start-Process -FilePath $fileDest -ArgumentList "/S" -Wait

Write-Host "Netbird installed successfully..."

$setupKey = Read-Host -Prompt "`nEnter a Netbird Setup Key (optional)"

if (!$setupKey) {
        Write-Host "`nRun 'netbird up' to connect."
        exit
}

Set-Location "C:\Program Files\Netbird"

.\netbird.exe up --setup-key $setupKey
