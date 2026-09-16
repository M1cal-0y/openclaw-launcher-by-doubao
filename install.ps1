# OpenClaw Launcher - 一键安装脚本 (by Doubao)
# 功能: 复制脚本到用户目录 + 创建桌面快捷方式

$ErrorActionPreference = "Stop"

Write-Host ""
Write-Host "============================================" -ForegroundColor Cyan
Write-Host "  OpenClaw Launcher (by Doubao) - Installer" -ForegroundColor Cyan
Write-Host "============================================" -ForegroundColor Cyan
Write-Host ""

# 1. 复制文件
$src = Split-Path -Parent $MyInvocation.MyCommand.Path
$dest = Join-Path $env:USERPROFILE "OpenClawLauncher"
if (-not (Test-Path $dest)) { New-Item -ItemType Directory -Path $dest -Force | Out-Null }

Copy-Item (Join-Path $src "launcher.ps1") (Join-Path $dest "launcher.ps1") -Force
Copy-Item (Join-Path $src "gateway_start.ps1") (Join-Path $dest "gateway_start.ps1") -Force
Write-Host "[1/3] 脚本已复制到: $dest" -ForegroundColor Green

# 2. 创建桌面快捷方式 (中文名: OpenClaw 启动器)
$ws = New-Object -ComObject WScript.Shell
$cnName = "OpenClaw " + [char]0x542F + [char]0x52A8 + [char]0x5668 + ".lnk"
$desktop = [Environment]::GetFolderPath("Desktop")
$lnkPath = Join-Path $desktop $cnName
$lnk = $ws.CreateShortcut($lnkPath)
$lnk.TargetPath = "powershell.exe"
$lnk.Arguments = '-NoProfile -ExecutionPolicy Bypass -File "' + $dest + '\launcher.ps1"'
$lnk.WorkingDirectory = $dest
$lnk.IconLocation = "C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe,0"
$lnk.Description = "OpenClaw Launcher by Doubao"
$lnk.Save()
Write-Host "[2/3] 桌面快捷方式已创建: $lnkPath" -ForegroundColor Green

# 3. 完成
Write-Host "[3/3] 安装完成！" -ForegroundColor Green
Write-Host ""
Write-Host "使用方法:" -ForegroundColor Yellow
Write-Host "  1. 双击桌面 [OpenClaw 启动器] 图标" -ForegroundColor White
Write-Host "  2. 点击 [打开对话界面]，浏览器自动打开聊天页面" -ForegroundColor White
Write-Host ""
Write-Host "前置要求: 已安装 OpenClaw 并完成模型配置 (.openclaw/openclaw.json)" -ForegroundColor DarkGray
Write-Host ""
Read-Host "按回车键退出"
