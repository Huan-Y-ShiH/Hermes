<#
.SYNOPSIS
    Hermes Desktop 快速启动器（Windows / PowerShell）

.DESCRIPTION
    设置 HERMES_HOME 和 HERMES_DESKTOP_HERMES_ROOT 后启动 Electron 桌面应用。
    必须先执行过 npm run build 生成 dist/ 目录。

.EXAMPLE
    .\desktop.ps1              # 启动桌面应用
    .\desktop.ps1 -Rebuild     # 重新构建后启动
#>

param([switch]$Rebuild)

$ErrorActionPreference = 'Stop'
$Root = $PSScriptRoot

# 1. 注入环境变量
$env:HERMES_HOME = Join-Path $Root 'workspace'
$env:HERMES_DESKTOP_HERMES_ROOT = $Root

# 2. 检查 workspace
if (-not (Test-Path $env:HERMES_HOME)) {
    Write-Error "workspace 目录不存在: $env:HERMES_HOME"
    exit 1
}

# 3. 可选重建
if ($Rebuild) {
    Write-Host "[hermes] 重新构建桌面应用..." -ForegroundColor Cyan
    Push-Location "$Root\apps\desktop"
    try {
        npm run build
        if ($LASTEXITCODE -ne 0) { throw "构建失败" }
    } finally { Pop-Location }
}

# 4. 检查 dist/
$distDir = Join-Path $Root 'apps\desktop\dist'
if (-not (Test-Path $distDir)) {
    Write-Host "[hermes] dist/ 不存在，正在构建..." -ForegroundColor Yellow
    Push-Location "$Root\apps\desktop"
    try {
        npm run build
        if ($LASTEXITCODE -ne 0) { throw "构建失败" }
    } finally { Pop-Location }
}

# 5. 启动 Electron
Write-Host "[hermes] HERMES_HOME = $env:HERMES_HOME" -ForegroundColor DarkGray
Write-Host "[hermes] 启动桌面应用..." -ForegroundColor Cyan

Push-Location "$Root\apps\desktop"
try {
    npx electron .
} finally {
    Pop-Location
}
