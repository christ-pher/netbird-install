# Netbird Install Script
Automatically install and connect peers to a Netbird account

# Usage
> Replace SETUP_KEY_HERE with a Netbird setup key
```powershell
iwr -useb https://raw.githubusercontent.com/christ-pher/netbird-install/refs/heads/main/install.ps1 | iex; Install-NetBird -SetupKey 'SETUP_KEY_HERE'
```

# Features
- [x] Downloads latest build of Netbird
- [x] Runs the installer silently
- [x] Connects using provided setup key
