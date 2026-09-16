# OpenClaw 启动器 (OpenClaw Launcher)

> 由 **Doubao（豆包 AI）** 创作 —— Windows 图形化启动器，让 OpenClaw 脱离终端，双击即用。

![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)

## 这是什么

OpenClaw 是一个强大的本地 AI Agent 框架，但日常使用需要敲终端命令（`openclaw gateway run` / `openclaw tui`），对普通用户不友好。

这个启动器提供了一个**中文图形界面**：

- 🖱️ 双击桌面图标即可打开
- 🌐 一键启动 Gateway 并自动在浏览器打开聊天页面
- ⏻ 一键停止服务
- 🔄 可设置开机自启，重启电脑后无需手动操作

## 功能

| 按钮 | 作用 |
|------|------|
| **打开对话界面** | 自动检查并后台启动 Gateway → 打开浏览器进入 OpenClaw 聊天页面（全程无终端） |
| **停止服务** | 一键停止后台 Gateway |
| **开机自启** | 开关开机自启，开启后重启电脑 Gateway 自动启动 |
| 状态显示 | 顶部实时显示 Gateway 运行状态 |

## 快速开始（最简单）

**方式一：一键安装（推荐）**

1. 点击页面右上角 **Code → Download ZIP** 下载项目
2. 解压到任意位置
3. 双击 **`install.bat`**
4. 桌面出现「OpenClaw 启动器」图标，双击即可使用

**方式二：手动安装**

```powershell
# 复制脚本
$dest = "$env:USERPROFILE\OpenClawLauncher"
New-Item -ItemType Directory -Path $dest -Force
Copy-Item launcher.ps1 $dest\
Copy-Item gateway_start.ps1 $dest\

# 创建桌面快捷方式（或直接用 PowerShell 运行）
powershell -NoProfile -ExecutionPolicy Bypass -File "$dest\launcher.ps1"
```

## 使用说明

1. 双击桌面 **「OpenClaw 启动器」**
2. 点击蓝色 **「打开对话界面」** 按钮
3. 浏览器自动打开聊天页面，直接中文对话
4. （建议）点击 **「开机自启」** 开启，以后重启电脑直接双击图标就能用

## 前置要求

- Windows 10 / 11（已安装 PowerShell）
- 已安装 OpenClaw（`npm install -g openclaw`）
- 已配置模型（`~/.openclaw/openclaw.json`，可使用本地 Ollama 或任意 OpenAI 兼容 API）

## 项目结构

```
openclaw-launcher-by-doubao/
├── launcher.ps1          # 图形化启动器主程序（WinForms 中文界面）
├── gateway_start.ps1     # Gateway 后台启动脚本（用于开机自启）
├── install.bat           # 一键安装入口
├── install.ps1           # 安装逻辑（复制脚本 + 创建桌面快捷方式）
├── README.md
└── LICENSE               # MIT License
```

## 工作原理

- `launcher.ps1` 基于 PowerShell WinForms 构建中文图形界面，无任何第三方依赖
- 点击「打开对话界面」后：
  1. 检测 Gateway 是否在运行（端口 `18789`）
  2. 未运行则后台启动（`openclaw gateway run`，日志写入 `C:\Users\Public\gateway_log.txt`）
  3. 通过 `openclaw dashboard --json --no-open` 获取带 Token 的页面地址
  4. 用默认浏览器打开聊天页面
- 开机自启通过注册表 `HKCU\...\Run` 实现，指向 `gateway_start.ps1`

## 常见问题

**Q: 点击「打开对话界面」没有反应？**
A: 确认已安装 OpenClaw（终端执行 `openclaw --version`）；查看日志 `C:\Users\Public\gateway_log.txt`。

**Q: 浏览器打开后页面空白？**
A: 等待 3-5 秒刷新，或点击「停止服务」后重新点「打开对话界面」。

**Q: 换模型怎么改？**
A: 修改 `~/.openclaw/openclaw.json` 中的模型配置即可，启动器自动使用最新配置。

## 许可证

[MIT License](LICENSE) — Copyright (c) 2026 Doubao（豆包 AI 创作）

## 致谢

- [OpenClaw](https://github.com/openclaw) — 底层 Agent 框架
- 由豆包 AI 为 OpenClaw 用户创作的本地适配工具
