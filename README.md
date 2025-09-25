# Netbird Install Script
Automatically install and connect peers to a Netbird account

# Usage
> Replace SETUP_KEY_HERE with a Netbird setup key
```powershell
powershell -c "irm christopher.dev/netbird.ps1 | iex"

powershell -c "irm https://raw.githubusercontent.com/christ-pher/netbird-install/refs/heads/main/install.ps1 | iex"
```

# Features
- [x] Downloads latest build of Netbird
- [x] Runs the installer silently
- [x] Connects using provided setup key
