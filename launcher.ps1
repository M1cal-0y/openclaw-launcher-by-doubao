# OpenClaw 启动器 - 图形化中文界面（无需终端）
# 功能：打开对话界面 / 停止服务 / 开机自启 / 状态显示 / 模型实时显示
# by Doubao

Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

# ---------- 工具函数 ----------
function Test-Gateway {
  $c = New-Object System.Net.Sockets.TcpClient
  try {
    $iar = $c.BeginConnect("127.0.0.1", 18789, $null, $null)
    $ok = $iar.AsyncWaitHandle.WaitOne(600)
    if ($ok) { $c.EndConnect($iar) }
    return $ok
  } catch { return $false } finally { $c.Close() }
}

function Stop-GatewayProc {
  $line = netstat -ano | findstr "18789" | findstr "LISTENING"
  if ($line) {
    $p2 = ($line.Trim() -split '\s+')[-1]
    if ($p2) { Stop-Process -Id $p2 -Force -ErrorAction SilentlyContinue }
  }
}

# ---------- 窗体 ----------
$form = New-Object System.Windows.Forms.Form
$form.Text = "OpenClaw 启动器"
$form.Size = New-Object System.Drawing.Size(470, 340)
$form.StartPosition = [System.Windows.Forms.FormStartPosition]::CenterScreen
$form.FormBorderStyle = [System.Windows.Forms.FormBorderStyle]::FixedDialog
$form.MaximizeBox = $false
$form.MinimizeBox = $true

# 状态标签
$lblStatus = New-Object System.Windows.Forms.Label
$lblStatus.Location = New-Object System.Drawing.Point(20, 18)
$lblStatus.Size = New-Object System.Drawing.Size(420, 32)
$lblStatus.Font = New-Object System.Drawing.Font("Microsoft YaHei UI", 12, [System.Drawing.FontStyle]::Bold)
$lblStatus.Text = "正在检测..."

# 模型信息（实时读取配置更新）
$lblModel = New-Object System.Windows.Forms.Label
$lblModel.Location = New-Object System.Drawing.Point(20, 58)
$lblModel.Size = New-Object System.Drawing.Size(420, 20)
$lblModel.Font = New-Object System.Drawing.Font("Microsoft YaHei UI", 9)
$lblModel.ForeColor = [System.Drawing.Color]::DimGray
$lblModel.Text = "模型: 读取中..."

# 提示
$lblHint = New-Object System.Windows.Forms.Label
$lblHint.Location = New-Object System.Drawing.Point(20, 84)
$lblHint.Size = New-Object System.Drawing.Size(420, 36)
$lblHint.Font = New-Object System.Drawing.Font("Microsoft YaHei UI", 8)
$lblHint.ForeColor = [System.Drawing.Color]::Gray
$lblHint.Text = "点击下方按钮，浏览器会自动打开 OpenClaw 聊天页面，全程无需使用终端。"

# 打开按钮
$btnOpen = New-Object System.Windows.Forms.Button
$btnOpen.Location = New-Object System.Drawing.Point(20, 135)
$btnOpen.Size = New-Object System.Drawing.Size(420, 46)
$btnOpen.Font = New-Object System.Drawing.Font("Microsoft YaHei UI", 11, [System.Drawing.FontStyle]::Bold)
$btnOpen.Text = "打开对话界面"
$btnOpen.BackColor = [System.Drawing.Color]::FromArgb(46, 120, 255)
$btnOpen.ForeColor = [System.Drawing.Color]::White
$btnOpen.FlatStyle = [System.Windows.Forms.FlatStyle]::Flat
$btnOpen.Cursor = [System.Windows.Forms.Cursors]::Hand

# 停止按钮
$btnStop = New-Object System.Windows.Forms.Button
$btnStop.Location = New-Object System.Drawing.Point(20, 192)
$btnStop.Size = New-Object System.Drawing.Size(200, 40)
$btnStop.Font = New-Object System.Drawing.Font("Microsoft YaHei UI", 10)
$btnStop.Text = "停止服务"
$btnStop.FlatStyle = [System.Windows.Forms.FlatStyle]::Flat

# 自启按钮
$btnAuto = New-Object System.Windows.Forms.Button
$btnAuto.Location = New-Object System.Drawing.Point(240, 192)
$btnAuto.Size = New-Object System.Drawing.Size(200, 40)
$btnAuto.Font = New-Object System.Drawing.Font("Microsoft YaHei UI", 10)
$btnAuto.Text = "开机自启: 检测中"
$btnAuto.FlatStyle = [System.Windows.Forms.FlatStyle]::Flat

# 底部信息
$lblFoot = New-Object System.Windows.Forms.Label
$lblFoot.Location = New-Object System.Drawing.Point(20, 250)
$lblFoot.Size = New-Object System.Drawing.Size(420, 25)
$lblFoot.Font = New-Object System.Drawing.Font("Microsoft YaHei UI", 8)
$lblFoot.ForeColor = [System.Drawing.Color]::DimGray
$lblFoot.Text = ""

$form.Controls.AddRange(@($lblStatus, $lblModel, $lblHint, $btnOpen, $btnStop, $btnAuto, $lblFoot))

# ---------- 逻辑 ----------
$runKey = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Run"

function Update-AutoBtn {
  $exists = (Get-ItemProperty $runKey -Name "OpenClawGateway" -ErrorAction SilentlyContinue) -ne $null
  $btnAuto.Text = if ($exists) { "开机自启: 开" } else { "开机自启: 关" }
}

# 实时读取当前配置的模型并更新标签（跟随 openclaw.json 变化）
function Update-ModelLabel {
  try {
    $cfgPath = Join-Path $env:USERPROFILE ".openclaw\openclaw.json"
    if (-not (Test-Path $cfgPath)) { return }
    $j = Get-Content $cfgPath -Raw -Encoding UTF8 | ConvertFrom-Json
    if (-not $j.models -or -not $j.models.providers) { return }
    $providers = $j.models.providers
    $pickedName = $null
    $src = ""
    # 优先英伟达云端
    if ($providers.PSObject.Properties.Name -contains "nvidia-nim") {
      $p = $providers."nvidia-nim"
      if ($p.models -and $p.models.Count -gt 0) {
        $m = $p.models[0]
        $pickedName = if ($m.name) { $m.name } else { $m.id }
        $src = "英伟达云端"
      }
    }
    # 否则取第一个可用 provider
    if (-not $pickedName) {
      foreach ($pn in $providers.PSObject.Properties.Name) {
        $p = $providers.$pn
        if ($p.models -and $p.models.Count -gt 0) {
          $m = $p.models[0]
          $pickedName = if ($m.name) { $m.name } else { $m.id }
          $src = if ($pn -eq "api-proxy-other") { "本地 Ollama" } else { $pn }
          break
        }
      }
    }
    if ($pickedName) {
      $lblModel.Text = "模型: $pickedName" + $(if ($src) { "（$src）" } else { "" })
    }
  } catch {
    # 读取失败保持原文本，不打断界面
  }
}

$btnOpen.Add_Click({
  $btnOpen.Enabled = $false
  $btnOpen.Text = "正在启动，请稍候..."
  $lblFoot.Text = "正在检查 Gateway 并打开浏览器..."
  $scriptBlock = {
    function T {
      $c = New-Object System.Net.Sockets.TcpClient
      try {
        $iar = $c.BeginConnect("127.0.0.1", 18789, $null, $null)
        $ok = $iar.AsyncWaitHandle.WaitOne(600)
        if ($ok) { $c.EndConnect($iar) }
        return $ok
      } catch { return $false } finally { $c.Close() }
    }
    if (-not (T)) {
      Start-Process -FilePath "cmd.exe" -ArgumentList '/c', 'openclaw gateway run > "C:\Users\Public\gateway_log.txt" 2>&1' -WindowStyle Hidden
      for ($i = 0; $i -lt 60; $i++) {
        Start-Sleep -Milliseconds 800
        if (T) { break }
      }
    }
    $url = "http://127.0.0.1:18789/"
    $raw = & openclaw dashboard --json --no-open 2>$null
    if ($raw) {
      try {
        $j = $raw | ConvertFrom-Json
        if ($j.browserUrl) { $url = $j.browserUrl }
      } catch {}
    }
    Start-Process $url
  }
  Start-Job -ScriptBlock $scriptBlock | Out-Null
  $recover = New-Object System.Windows.Forms.Timer
  $recover.Interval = 20000
  $recover.Add_Tick({
    $btnOpen.Enabled = $true
    $btnOpen.Text = "打开对话界面"
    $recover.Stop()
  })
  $recover.Start()
})

$btnStop.Add_Click({
  Stop-GatewayProc
  Start-Sleep -Milliseconds 500
  $lblFoot.Text = "服务已停止"
})

$btnAuto.Add_Click({
  $exists = (Get-ItemProperty $runKey -Name "OpenClawGateway" -ErrorAction SilentlyContinue) -ne $null
  if ($exists) {
    Remove-ItemProperty $runKey -Name "OpenClawGateway" -ErrorAction SilentlyContinue
    $lblFoot.Text = "已关闭开机自启"
  } else {
    $val = 'powershell -NoProfile -ExecutionPolicy Bypass -WindowStyle Hidden -File "' + $env:USERPROFILE + '\OpenClawLauncher\gateway_start.ps1"'
    New-ItemProperty $runKey -Name "OpenClawGateway" -Value $val -PropertyType String -Force | Out-Null
    $lblFoot.Text = "已开启开机自启，重启电脑后 Gateway 自动启动"
  }
  Update-AutoBtn
})

# 状态与模型实时刷新（每 3 秒）
$timer = New-Object System.Windows.Forms.Timer
$timer.Interval = 3000
$timer.Add_Tick({
  $up = Test-Gateway
  if ($up) {
    $lblStatus.Text = "● Gateway 运行中"
    $lblStatus.ForeColor = [System.Drawing.Color]::FromArgb(0, 150, 60)
  } else {
    $lblStatus.Text = "○ Gateway 未运行"
    $lblStatus.ForeColor = [System.Drawing.Color]::DimGray
  }
  Update-ModelLabel
})
$timer.Start()

$form.Add_Shown({
  $up = Test-Gateway
  if ($up) {
    $lblStatus.Text = "● Gateway 运行中"
    $lblStatus.ForeColor = [System.Drawing.Color]::FromArgb(0, 150, 60)
  } else {
    $lblStatus.Text = "○ Gateway 未运行"
    $lblStatus.ForeColor = [System.Drawing.Color]::DimGray
  }
  Update-AutoBtn
  Update-ModelLabel
})

[System.Windows.Forms.Application]::EnableVisualStyles()
[System.Windows.Forms.Application]::Run($form)
