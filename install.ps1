#Requires -Version 5.1
<#
.SYNOPSIS
    Super AI Code Skill — 一键安装脚本 (Windows)
.DESCRIPTION
    将 Super AI Code Skill 安装到 OpenCode 的 skills 目录。
.PARAMETER Project
    安装到当前项目 (.opencode\skills\)，默认安装到全局。
.PARAMETER Update
    更新已有安装。
.PARAMETER Profile
    预置策略 (balanced|strict|minimal)，默认 balanced。
.EXAMPLE
    .\install.ps1
    .\install.ps1 -Project
    .\install.ps1 -Update
    .\install.ps1 -Profile strict
#>

param(
    [switch]$Project,
    [switch]$Update,
    [string]$Profile = "balanced"
)

$ErrorActionPreference = "Stop"
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path

Write-Host "=== Super AI Code Skill 安装 ===" -ForegroundColor Green
Write-Host ""

# 检查必要文件
if (-not (Test-Path (Join-Path $ScriptDir "super-core"))) {
    Write-Host "错误: 未找到 super-core 目录，请从项目根目录运行此脚本" -ForegroundColor Red
    exit 1
}

# 确定目标路径
$InstallMode = if ($Project) { "project" } elseif ($Update) { "update" } else { "global" }

if ($Project) {
    $SkillDir = Join-Path (Get-Location) ".opencode\skills\super-aicode"
    $ConfigFile = Join-Path (Get-Location) ".super.yaml"
} else {
    $SkillDir = "$env:USERPROFILE\.config\opencode\skills\super-aicode"
    $ConfigFile = "$env:USERPROFILE\.super.yaml"
}

Write-Host "安装模式: $InstallMode"
Write-Host "目标路径: $SkillDir"
Write-Host "配置文件: $ConfigFile"
Write-Host "预置策略: $Profile"
Write-Host ""

# 创建目录
New-Item -ItemType Directory -Force -Path $SkillDir | Out-Null

if ($Update -and (Test-Path $SkillDir)) {
    Write-Host "更新模式: 覆盖已有文件..." -ForegroundColor Yellow
}

# 复制技能文件
Write-Host "复制技能文件..."
$skillDirs = @(
    "super-core", "super-frontend",
    "super-backend-java", "super-backend-node", "super-backend-go", "super-backend-python",
    "super-backend-common",
    "super-design-icon", "super-deploy", "super-config",
    "super-api-doc", "super-test", "super-log", "super-sse", "super-mock-data"
)
foreach ($dir in $skillDirs) {
    $src = Join-Path $ScriptDir $dir
    if (Test-Path $src) {
        Copy-Item -Recurse -Force $src $SkillDir
        Write-Host "  V $dir"
    }
}

# 复制配置模板和预置策略
Write-Host "复制配置模板..."
$assetDirs = @("profiles", "templates")
foreach ($dir in $assetDirs) {
    $src = Join-Path $ScriptDir $dir
    if (Test-Path $src) {
        Copy-Item -Recurse -Force $src $SkillDir
        Write-Host "  V $dir"
    }
}

# 创建全局配置文件（仅全局安装时）
if (-not $Project) {
    if (Test-Path $ConfigFile) {
        Write-Host "配置文件已存在，跳过创建: $ConfigFile" -ForegroundColor Yellow
        Write-Host "如需重置，请删除该文件后重新安装" -ForegroundColor Yellow
    } else {
        $templateFile = Join-Path $ScriptDir "templates\global.yaml"
        Copy-Item $templateFile $ConfigFile
        Write-Host "  V 全局配置已创建: $ConfigFile"
    }
}

# 验证并统计
Write-Host ""
Write-Host "=== 安装完成 ===" -ForegroundColor Green
Write-Host ""

$skillCount = (Get-ChildItem -Path $SkillDir -Recurse -Filter "SKILL.md" -Depth 2).Count
$promptCount = (Get-ChildItem -Path $SkillDir -Recurse -Filter "*.md" -Directory "prompts").Count
Write-Host "已安装技能: $skillCount 个"
Write-Host "已安装规则: $promptCount 条"
Write-Host ""

# 后续步骤
Write-Host "后续步骤:" -ForegroundColor Yellow
Write-Host "  1. 编辑配置文件: $ConfigFile"
Write-Host "  2. 重启 OpenCode / Claude Code"
Write-Host ""

if ($Project) {
    Write-Host "项目配置提示:" -ForegroundColor Yellow
    Write-Host "  如需覆盖全局规则，在项目根目录创建 .super.yaml"
    Write-Host "  模板: Copy-Item $SkillDir\templates\project.yaml .\.super.yaml"
    Write-Host ""
}

Write-Host "验证方式:" -ForegroundColor Green
Write-Host '  在 Agent 中输入 "写一个创建订单的 REST 接口"'
Write-Host "  预期 Agent 先输出任务方案，再按规则生成代码并自检"
