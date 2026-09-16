# OpenClaw Gateway 开机自启脚本（隐藏窗口运行，无界面）
# 检测 Gateway 是否运行，未运行则后台启动

function Test-GatewayPort {
  $c = New-Object System.Net.Sockets.TcpClient
  try {
    $iar = $c.BeginConnect("127.0.0.1", 18789, $null, $null)
    $ok = $iar.AsyncWaitHandle.WaitOne(600)
    if ($ok) { $c.EndConnect($iar) }
    return $ok
  } catch { return $false } finally { $c.Close() }
}

if (-not (Test-GatewayPort)) {
  Start-Process -FilePath "cmd.exe" -ArgumentList '/c', 'openclaw gateway run > "C:\Users\Public\gateway_log.txt" 2>&1' -WindowStyle Hidden
}
