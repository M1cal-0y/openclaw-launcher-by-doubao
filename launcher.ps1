# OpenClaw 启动器 - 图形化中文界面（无需终端）
# 功能：打开对话界面 / 问一问快速提问 / 停止服务 / 开机自启 / 状态显示
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
$form.Size = New-Object System.Drawing.Size(470, 680)
$form.StartPosition = [System.Windows.Forms.FormStartPosition]::CenterScreen
$form.FormBorderStyle = [System.Windows.Forms.FormBorderStyle]::FixedDialog
$form.MaximizeBox = $false
$form.MinimizeBox = $true

# 状态标签
$lblStatus = New-Object System.Windows.Forms.Label
$lblStatus.Location = New-Object System.Drawing.Point(20, 12)
$lblStatus.Size = New-Object System.Drawing.Size(420, 28)
$lblStatus.Font = New-Object System.Drawing.Font("Microsoft YaHei UI", 12, [System.Drawing.FontStyle]::Bold)
$lblStatus.Text = "正在检测..."

# 模型信息
$lblModel = New-Object System.Windows.Forms.Label
$lblModel.Location = New-Object System.Drawing.Point(20, 48)
$lblModel.Size = New-Object System.Drawing.Size(420, 20)
$lblModel.Font = New-Object System.Drawing.Font("Microsoft YaHei UI", 9)
$lblModel.ForeColor = [System.Drawing.Color]::DimGray
$lblModel.Text = "模型: Nemotron 3 Ultra 550B（英伟达云端）"

# 提示
$lblHint = New-Object System.Windows.Forms.Label
$lblHint.Location = New-Object System.Drawing.Point(20, 72)
$lblHint.Size = New-Object System.Drawing.Size(420, 18)
$lblHint.Font = New-Object System.Drawing.Font("Microsoft YaHei UI", 8)
$lblHint.ForeColor = [System.Drawing.Color]::Gray
$lblHint.Text = "下方可直接提问，回复附带引用信息，方便定位问题。"

# 打开按钮
$btnOpen = New-Object System.Windows.Forms.Button
$btnOpen.Location = New-Object System.Drawing.Point(20, 100)
$btnOpen.Size = New-Object System.Drawing.Size(420, 40)
$btnOpen.Font = New-Object System.Drawing.Font("Microsoft YaHei UI", 11, [System.Drawing.FontStyle]::Bold)
$btnOpen.Text = "打开对话界面"
$btnOpen.BackColor = [System.Drawing.Color]::FromArgb(46, 120, 255)
$btnOpen.ForeColor = [System.Drawing.Color]::White
$btnOpen.FlatStyle = [System.Windows.Forms.FlatStyle]::Flat
$btnOpen.Cursor = [System.Windows.Forms.Cursors]::Hand

# 停止按钮
$btnStop = New-Object System.Windows.Forms.Button
$btnStop.Location = New-Object System.Drawing.Point(20, 150)
$btnStop.Size = New-Object System.Drawing.Size(200, 36)
$btnStop.Font = New-Object System.Drawing.Font("Microsoft YaHei UI", 10)
$btnStop.Text = "停止服务"
$btnStop.FlatStyle = [System.Windows.Forms.FlatStyle]::Flat

# 自启按钮
$btnAuto = New-Object System.Windows.Forms.Button
$btnAuto.Location = New-Object System.Drawing.Point(240, 150)
$btnAuto.Size = New-Object System.Drawing.Size(200, 36)
$btnAuto.Font = New-Object System.Drawing.Font("Microsoft YaHei UI", 10)
$btnAuto.Text = "开机自启: 检测中"
$btnAuto.FlatStyle = [System.Windows.Forms.FlatStyle]::Flat

# 底部信息
$lblFoot = New-Object System.Windows.Forms.Label
$lblFoot.Location = New-Object System.Drawing.Point(20, 196)
$lblFoot.Size = New-Object System.Drawing.Size(420, 22)
$lblFoot.Font = New-Object System.Drawing.Font("Microsoft YaHei UI", 8)
$lblFoot.ForeColor = [System.Drawing.Color]::DimGray
$lblFoot.Text = ""

# ---------- 问一问面板 ----------
$grpAsk = New-Object System.Windows.Forms.GroupBox
$grpAsk.Text = "问一问（快速提问）"
$grpAsk.Location = New-Object System.Drawing.Point(12, 226)
$grpAsk.Size = New-Object System.Drawing.Size(436, 402)
$grpAsk.Font = New-Object System.Drawing.Font("Microsoft YaHei UI", 10)

# 输入框
$txtInput = New-Object System.Windows.Forms.TextBox
$txtInput.Location = New-Object System.Drawing.Point(12, 28)
$txtInput.Size = New-Object System.Drawing.Size(300, 60)
$txtInput.Multiline = $true
$txtInput.ScrollBars = [System.Windows.Forms.ScrollBars]::Vertical
$txtInput.Font = New-Object System.Drawing.Font("Microsoft YaHei UI", 9)

# 发送按钮
$btnAsk = New-Object System.Windows.Forms.Button
$btnAsk.Location = New-Object System.Drawing.Point(322, 28)
$btnAsk.Size = New-Object System.Drawing.Size(100, 60)
$btnAsk.Font = New-Object System.Drawing.Font("Microsoft YaHei UI", 10, [System.Drawing.FontStyle]::Bold)
$btnAsk.Text = "发送"
$btnAsk.BackColor = [System.Drawing.Color]::FromArgb(46, 120, 255)
$btnAsk.ForeColor = [System.Drawing.Color]::White
$btnAsk.FlatStyle = [System.Windows.Forms.FlatStyle]::Flat
$btnAsk.Cursor = [System.Windows.Forms.Cursors]::Hand

# 回复输出框
$txtOutput = New-Object System.Windows.Forms.RichTextBox
$txtOutput.Location = New-Object System.Drawing.Point(12, 98)
$txtOutput.Size = New-Object System.Drawing.Size(410, 220)
$txtOutput.ReadOnly = $true
$txtOutput.Font = New-Object System.Drawing.Font("Microsoft YaHei UI", 9)
$txtOutput.BackColor = [System.Drawing.Color]::FromArgb(250, 250, 252)
$txtOutput.Text = "在这里输入问题，点击「发送」，回复会显示在这里。"

# 引用标签
$lblRef = New-Object System.Windows.Forms.Label
$lblRef.Location = New-Object System.Drawing.Point(12, 328)
$lblRef.Size = New-Object System.Drawing.Size(410, 60)
$lblRef.Font = New-Object System.Drawing.Font("Microsoft YaHei UI", 8)
$lblRef.ForeColor = [System.Drawing.Color]::FromArgb(0, 120, 190)
$lblRef.Text = "📎 引用: 暂无"

$grpAsk.Controls.AddRange(@($txtInput, $btnAsk, $txtOutput, $lblRef))

$form.Controls.AddRange(@($lblStatus, $lblModel, $lblHint, $btnOpen, $btnStop, $btnAuto, $lblFoot, $grpAsk))

# ---------- 逻辑 ----------
$runKey = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Run"

function Update-AutoBtn {
  $exists = (Get-ItemProperty $runKey -Name "OpenClawGateway" -ErrorAction SilentlyContinue) -ne $null
  $btnAuto.Text = if ($exists) { "开机自启: 开" } else { "开机自启: 关" }
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

# ---------- 问一问逻辑 ----------
$script:askJob = $null

$btnAsk.Add_Click({
  $q = $txtInput.Text.Trim()
  if (-not $q) {
    $txtOutput.Text = "请先输入问题。"
    return
  }
  if (-not (Test-Gateway)) {
    $txtOutput.Text = "Gateway 未运行，请先点击「打开对话界面」启动服务，然后再提问。"
    return
  }
  $btnAsk.Enabled = $false
  $btnAsk.Text = "思考中..."
  $txtOutput.Text = "正在提问，请稍候（云端模型通常需要几秒到几十秒）..."
  $lblRef.Text = "📎 引用: 处理中..."

  $script:askJob = Start-Job -ArgumentList $q -ScriptBlock {
    param($question)
    function T {
      $c = New-Object System.Net.Sockets.TcpClient
      try {
        $iar = $c.BeginConnect("127.0.0.1", 18789, $null, $null)
        $ok = $iar.AsyncWaitHandle.WaitOne(600)
        if ($ok) { $c.EndConnect($iar) }
        return $ok
      } catch { return $false } finally { $c.Close() }
    }
    if (-not (T)) { return "Gateway 未运行" }
    [Console]::OutputEncoding = [System.Text.Encoding]::UTF8
    $out = & openclaw agent --agent main --message $question --json 2>$null | Out-String
    if (-not $out) { return "调用失败，请确认 OpenClaw 已正确安装" }
    $start = $out.IndexOf('{')
    if ($start -lt 0) { return "未获得有效回复" }
    $json = $out.Substring($start)
    try {
      $j = $json | ConvertFrom-Json
      if (-not $j.result) { return "回复格式异常" }
      $text = $j.result.payloads[0].text
      $model = $j.result.meta.agentMeta.model
      $tools = @($j.result.meta.terminalReceipt.successfulToolNames)
      return [pscustomobject]@{ Text = $text; Model = $model; Tools = ($tools -join ", ") }
    } catch {
      return "解析回复失败: " + $_.Exception.Message
    }
  }
})

# 轮询 job 结果
$askTimer = New-Object System.Windows.Forms.Timer
$askTimer.Interval = 1000
$askTimer.Add_Tick({
  if (-not $script:askJob) { return }
  $st = $script:askJob.State
  if ($st -eq 'Completed') {
    $askTimer.Stop()
    $result = Receive-Job $script:askJob
    Remove-Job $script:askJob -Force
    $script:askJob = $null
    if ($result -is [pscustomobject] -and $result.Text) {
      $txtOutput.Text = $result.Text
      $refs = @("模型: $($result.Model)")
      if ($result.Tools) { $refs += "工具: $($result.Tools)" }
      $lblRef.Text = "📎 引用: " + ($refs -join "  ·  ")
    } else {
      $txtOutput.Text = [string]$result
      $lblRef.Text = "📎 引用: 暂无"
    }
    $btnAsk.Enabled = $true
    $btnAsk.Text = "发送"
  } elseif ($st -eq 'Failed') {
    $askTimer.Stop()
    $txtOutput.Text = "请求失败：" + [string](Receive-Job $script:askJob -ErrorAction SilentlyContinue)
    $lblRef.Text = "📎 引用: 暂无"
    Remove-Job $script:askJob -Force
    $script:askJob = $null
    $btnAsk.Enabled = $true
    $btnAsk.Text = "发送"
  }
})
$askTimer.Start()

# 回车快捷发送（输入框 Ctrl+Enter 发送）
$txtInput.Add_KeyDown({
  param($sender, $e)
  if ($e.Control -and $e.KeyCode -eq [System.Windows.Forms.Keys]::Enter) {
    $e.SuppressKeyPress = $true
    $btnAsk.PerformClick()
  }
})

# 状态刷新
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
})

[System.Windows.Forms.Application]::EnableVisualStyles()
[System.Windows.Forms.Application]::Run($form)
