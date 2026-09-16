# install.ps1 BOM + syntax check
$f = $env:USERPROFILE + "\GitHubProjects\openclaw-launcher-by-doubao\install.ps1"
$c = [System.IO.File]::ReadAllText($f, [System.Text.Encoding]::UTF8)
[System.IO.File]::WriteAllText($f, $c, (New-Object System.Text.UTF8Encoding($true)))
Write-Output "install.ps1 BOM OK"
$errs = $null
[System.Management.Automation.Language.Parser]::ParseFile($f, [ref]$null, [ref]$errs) | Out-Null
if ($errs.Count -gt 0) { $errs | ForEach-Object { Write-Output $_.Message } } else { Write-Output "Syntax OK" }

# Find git.exe
$candidates = @(
  "C:\Program Files\Git\cmd\git.exe",
  "C:\Program Files\Git\bin\git.exe",
  "$env:LOCALAPPDATA\Programs\Git\cmd\git.exe",
  "$env:ProgramFiles(x86)\Git\cmd\git.exe"
)
foreach ($p in $candidates) { if (Test-Path $p) { Write-Output ("GIT FOUND: " + $p) } }
