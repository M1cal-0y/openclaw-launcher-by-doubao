$cmd = Get-Command git -ErrorAction SilentlyContinue
if ($cmd) { Write-Output ("git in PATH: " + $cmd.Source) } else { Write-Output "git NOT in PATH" }
$dirs = @(
  "C:\Program Files\Git",
  "$env:LOCALAPPDATA\Programs\Git",
  "C:\Program Files (x86)\Git"
)
foreach ($d in $dirs) {
  if (Test-Path $d) {
    Write-Output ("DIR EXISTS: " + $d)
    Get-ChildItem $d -Filter "git.exe" -Recurse -Depth 2 -ErrorAction SilentlyContinue | Select-Object -First 3 | ForEach-Object { Write-Output ("  " + $_.FullName) }
  }
}
# winget package record
winget list --id Git.Git 2>$null | Select-Object -Last 3
