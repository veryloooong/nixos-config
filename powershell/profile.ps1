# powershell 7+ only

Import-Module PSReadline
Import-Module posh-git
Import-Module PSFzf

if (Get-Command -Name oh-my-posh -ErrorAction SilentlyContinue) {
  if ($IsWindows) {
    oh-my-posh init pwsh --config "$env:LOCALAPPDATA\omp.toml" | Invoke-Expression
  }
  elseif ($IsLinux) { 
    oh-my-posh init pwsh --config "~/.config/omp.toml" | Invoke-Expression
  }
}

if (Get-Command -Name zoxide -ErrorAction SilentlyContinue) {
  Invoke-Expression (& { (zoxide init powershell --cmd cd | Out-String) })
}

if (Get-Command -Name uv -ErrorAction SilentlyContinue) {
  Invoke-Expression (& { (uv generate-shell-completion powershell | Out-String) })
}

if (Get-Command -Name rustup -ErrorAction SilentlyContinue) {
  Invoke-Expression (& { (rustup completions powershell) | Out-String })
}

Set-PSReadlineKeyHandler -Key UpArrow -Function HistorySearchBackward
Set-PSReadlineKeyHandler -Key DownArrow -Function HistorySearchForward
Set-PSReadlineKeyHandler -Key Tab -Function MenuComplete
Set-PSReadlineKeyHandler -Key 'Ctrl+d' -Function DeleteCharOrExit
Set-PSReadLineKeyHandler -Chord "Ctrl+f" -Function ForwardWord

Set-PSReadlineOption -PredictionSource History

Set-PsFzfOption -PSReadlineChordProvider 'Ctrl+t' -PSReadlineChordReverseHistory 'Ctrl+r'
 
if ($IsWindows) {
  Set-Alias vswhere -Value "${env:ProgramFiles(x86)}\Microsoft Visual Studio\Installer\vswhere.exe"

  function Start-VisualStudioEnv {
    $vs = vswhere -prerelease -format json -latest | ConvertFrom-Json
    $installationPath = $vs.installationPath
    Import-Module "$installationPath\Common7\Tools\Microsoft.VisualStudio.DevShell.dll"
    Enter-VsDevShell $vs.instanceId -SkipAutomaticLocation
  }

  function Get-FullCmdPath {
    param (
      [string]$name
    )

    Get-Command -Name $name | Select-Object -ExpandProperty Path
  }

  Set-Alias -Name which -Value Get-FullCmdPath
}

function ConvertFrom-Base64 {
  param (
    [switch]$AsByteArray,
    [string]$base64String
  )

  $bytes = [System.Convert]::FromBase64String($base64String)
  if ($AsByteArray) {
    return $bytes
  }
  $decodedString = [System.Text.Encoding]::UTF8.GetString($bytes)
  return $decodedString
}

function ConvertTo-Base64 {
  param (
    [string]$string,
    [byte[]]$bytes,
    [switch]$FromByteArray
  )

  # if $FromByteArray is set, convert the byte array to a base64 string
  if ($FromByteArray) {
    return [System.Convert]::ToBase64String($bytes)
  }

  # if $string is set, convert the string to a byte array and then to a base64 string
  if ($string) {
    $bytes = [System.Text.Encoding]::UTF8.GetBytes($string)
    return [System.Convert]::ToBase64String($bytes)
  }
  # if neither $string nor $bytes is set, return an empty string
  return ''
}
