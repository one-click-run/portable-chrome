param (
    [string]$selectedMatch = $env:ONE_CLICK_RUN_PORTABLE_CHROME_SELECTEDMATCH
)

$ErrorActionPreference = "Stop"

# 如果没有传入版本，则获取可选版本并弹出选择界面
if (-not $selectedMatch) {
    Write-Output "获取可选择的版本..."
    $url = "https://github.com/one-click-run/portable-chrome/releases/expanded_assets/chrome"
    $response = Invoke-WebRequest -Uri $url
    $htmlContent = $response.Content
    $pattern = 'chrome-(\d+).zip'
    $matches = [regex]::Matches($htmlContent, $pattern)
    $uniqueMatches = @{}
    foreach ($match in $matches) {
        $uniqueMatches[$match.Value] = $true
    }

    # 弹出选择界面
    $selectedMatch = $uniqueMatches.Keys | Out-GridView -Title "Select a match" -OutputMode Single

    # 如果用户没有选择任何版本，退出脚本
    if ([string]::IsNullOrEmpty($selectedMatch)) {
        Write-Output "用户没有选择任何版本, 脚本将退出..."
        exit
    }
}

Write-Output "用户选择了: $selectedMatch"

# 下载 Chrome 安装包
Write-Output "开始下载 Chrome 安装包..."
$downloadUrl = "https://github.com/one-click-run/portable-chrome/releases/download/chrome/$selectedMatch"
$installerPath = "chrome-installer.zip"
Invoke-WebRequest -Uri $downloadUrl -OutFile $installerPath
Write-Output "下载完成..."

# 设置解压路径（临时路径）
$tempChromePath = Join-Path -Path (Get-Location) -ChildPath "chrome"

# 设置最终目标路径（便携版路径）
$finalChromePath = Join-Path -Path (Get-Location) -ChildPath "OCR-portable-chrome"

# 如果目标路径不存在，则创建
if (-not (Test-Path -Path $tempChromePath)) {
    New-Item -Path $tempChromePath -ItemType Directory
}

# 解压 Chrome 安装包
Write-Host "使用 PowerShell 解压 Chrome 安装包..."
Expand-Archive -Path $installerPath -DestinationPath $tempChromePath

# 删除安装包
Remove-Item -Path $installerPath -Force

# 重命名解压后的 Chrome 文件夹为 OCR-portable-chrome
Write-Host "重命名解压后的文件夹为 OCR-portable-chrome..."
if (Test-Path -Path $finalChromePath) {
    Remove-Item -Recurse -Force $finalChromePath  # 删除已存在的目标文件夹
}
Rename-Item -Path (Join-Path -Path $tempChromePath -ChildPath "Chrome-bin") -NewName "OCR-portable-chrome"

# 将 OCR-portable-chrome 移动到上层目录
Write-Host "将 OCR-portable-chrome 移动到上层目录..."
Move-Item -Path (Join-Path -Path $tempChromePath -ChildPath "OCR-portable-chrome") -Destination (Get-Location)

# 删除临时目录
Write-Host "删除临时目录..."
Remove-Item -Recurse -Force $tempChromePath

# 创建 CMD 启动脚本 (将其放在 OCR-portable-chrome 的上层目录)
Write-Host "创建启动 CMD 脚本..."
$startChromeCmdPath = Join-Path -Path (Get-Location) -ChildPath "start_chrome.cmd"
@"
@echo off
set chromePath=%~dp0OCR-portable-chrome\chrome.exe
set flagsFile=%~dp0OCR-portable-chrome\chrome_flags.txt

start "" "%chromePath%" --user-data-dir=%~dp0OCR-portable-chrome\User_Data --no-default-browser-check --no-first-run --disable-background-networking --disable-component-update --disable-sync
"@ | Set-Content -Path $startChromeCmdPath

Write-Output "完成"
