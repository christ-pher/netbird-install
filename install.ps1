#requires -version 5.1
function Install-NetBird {
  [CmdletBinding(SupportsShouldProcess)]
  param(
    [Parameter(Mandatory = $true)]
    [string]$SetupKey
  )

  # --- Admin check (installation typically needs elevation)
  $isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
  if (-not $isAdmin) {
    throw "This script must be run from an elevated (Run as Administrator) PowerShell."
  }

  $downloadUrl = 'https://pkgs.netbird.io/windows/x64'
  $installer   = Join-Path $env:TEMP 'netbird_installer.exe'

  Write-Host "Downloading NetBird installer from $downloadUrl ..."
  try {
    # Follow redirects and write to a fixed filename
    Invoke-WebRequest -Uri $downloadUrl -UseBasicParsing -OutFile $installer -MaximumRedirection 10 -ErrorAction Stop
  } catch {
    throw "Download failed: $($_.Exception.Message)"
  }

  if (-not (Test-Path $installer)) {
    throw "Download appears to have failed: '$installer' not found."
  }

  Write-Host "Running silent installer ..."
  $proc = Start-Process -FilePath $installer -ArgumentList '/S' -Wait -PassThru
  if ($null -eq $proc -or $proc.ExitCode -ne 0) {
    throw "Installer exited with code $($proc.ExitCode)."
  }

  # Try to resolve netbird.exe
  function Resolve-NetBirdPath {
    $cmd = Get-Command 'netbird' -ErrorAction SilentlyContinue
    if ($cmd -and $cmd.Source) { return $cmd.Source }

    $candidates = @(
      "$env:ProgramFiles\NetBird\bin\netbird.exe",
      "$env:ProgramFiles\NetBird\netbird.exe",
      "$env:ProgramFiles(x86)\NetBird\bin\netbird.exe",
      "$env:ProgramFiles(x86)\NetBird\netbird.exe"
    )
    foreach ($p in $candidates) {
      if (Test-Path $p) { return $p }
    }
    return $null
  }

  # Some installers update PATH for new sessions only; try a short wait & re-check
  Start-Sleep -Seconds 2
  $netbirdExe = Resolve-NetBirdPath
  if (-not $netbirdExe) {
    # One more attempt: refresh PATH from registry for the current process
    try {
      $machinePath = [Microsoft.Win32.Registry]::LocalMachine.OpenSubKey('SYSTEM\CurrentControlSet\Control\Session Manager\Environment').GetValue('Path','')
      $userPath    = [Microsoft.Win32.Registry]::CurrentUser.OpenSubKey('Environment').GetValue('Path','')
      $env:Path = ($machinePath, $userPath, $env:Path -join ';') -split ';' | Select-Object -Unique -join ';'
      $netbirdExe = Resolve-NetBirdPath
    } catch { }
  }

  if (-not $netbirdExe) {
    throw "Could not find 'netbird.exe' after install. Try opening a new elevated PowerShell and run: netbird up --setup-key $SetupKey"
  }

  Write-Host "Bringing NetBird up with provided setup key ..."
  $up = Start-Process -FilePath $netbirdExe -ArgumentList @('up','--setup-key', $SetupKey) -Wait -PassThru
  if ($up.ExitCode -ne 0) {
    throw "'netbird up' exited with code $($up.ExitCode)."
  }

  Write-Host "✅ NetBird installed and connected successfully."
}

# If someone runs the script file directly (not via iwr|iex), allow $args[0]
if ($MyInvocation.InvocationName -ne '.') {
  if ($args.Count -ge 1) {
    Install-NetBird -SetupKey $args[0]
  } else {
    Write-Host "Loaded Install-NetBird. Usage examples:"
    Write-Host "  Install-NetBird -SetupKey 'YOUR_SETUP_KEY'"
  }
}
