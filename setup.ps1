<#
.SYNOPSIS
    dotfiles セットアップスクリプト
.DESCRIPTION
    Starship, フォント, VS Code 拡張機能のインストールと
    設定ファイルのリンク/コピーを作成します。
    管理者権限がなくても動作します。
#>

param(
    [switch]$SkipInstall,
    [switch]$SkipSymlinks
)

$ErrorActionPreference = "Stop"
$DotfilesDir = $PSScriptRoot

Write-Host "`n=== dotfiles setup ===" -ForegroundColor Cyan

# ─── 1. Starship インストール ───
if (-not $SkipInstall) {
    Write-Host "`n[1/3] Starship をインストール中..." -ForegroundColor Yellow
    if (Get-Command starship -ErrorAction SilentlyContinue) {
        Write-Host "  Starship は既にインストール済みです" -ForegroundColor Green
    } else {
        winget install --id Starship.Starship --scope user --accept-source-agreements --accept-package-agreements
    }

    # ─── 2. フォント (UDEV Gothic 35NFLG) ───
    Write-Host "`n[2/3] UDEV Gothic 35NFLG フォントをインストール中..." -ForegroundColor Yellow
    $FontDir = "$env:LOCALAPPDATA\Microsoft\Windows\Fonts"
    $FontExists = Get-ChildItem -Path $FontDir -Filter "UDEVGothic35NFLG*" -ErrorAction SilentlyContinue
    if ($FontExists) {
        Write-Host "  UDEV Gothic 35NFLG は既にインストール済みです" -ForegroundColor Green
    } else {
        $TempDir = "$env:TEMP\udev-gothic"
        New-Item -ItemType Directory -Path $TempDir -Force | Out-Null

        # GitHub API で最新リリースを取得
        $Release = Invoke-RestMethod -Uri "https://api.github.com/repos/yuru7/udev-gothic/releases/latest"
        $Asset = $Release.assets | Where-Object { $_.name -match "UDEVGothic_NF_v.*\.zip$" } | Select-Object -First 1
        $ZipPath = "$TempDir\$($Asset.name)"

        Write-Host "  ダウンロード中: $($Asset.name)"
        Invoke-WebRequest -Uri $Asset.browser_download_url -OutFile $ZipPath
        Expand-Archive -Path $ZipPath -DestinationPath $TempDir -Force

        # 35NFLG フォントのみインストール
        $FontFiles = Get-ChildItem -Path $TempDir -Recurse -Filter "UDEVGothic35NFLG*.ttf"
        foreach ($Font in $FontFiles) {
            Copy-Item -Path $Font.FullName -Destination $FontDir -Force
            # フォントレジストリに登録
            $RegPath = "HKCU:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Fonts"
            $FontName = [System.IO.Path]::GetFileNameWithoutExtension($Font.Name) + " (TrueType)"
            New-ItemProperty -Path $RegPath -Name $FontName -Value $Font.FullName -PropertyType String -Force | Out-Null
        }
        Write-Host "  フォントをインストールしました ($($FontFiles.Count) ファイル)" -ForegroundColor Green

        Remove-Item -Path $TempDir -Recurse -Force
    }

    # ─── 3. VS Code 拡張機能 ───
    Write-Host "`n[3/3] VS Code 拡張機能をインストール中..." -ForegroundColor Yellow
    $Extensions = @(
        "Catppuccin.catppuccin-vsc"
        "Catppuccin.catppuccin-vsc-icons"
        "oderwat.indent-rainbow"
        "usernamehw.errorlens"
        "naumovs.color-highlight"
        "BrandonKirbyson.vscode-animations"
    )
    foreach ($Ext in $Extensions) {
        Write-Host "  $Ext"
        code --install-extension $Ext --force 2>$null
    }
    Write-Host "  拡張機能のインストール完了" -ForegroundColor Green
}

# ─── 設定ファイルの配置 ───
if (-not $SkipSymlinks) {
    Write-Host "`n設定ファイルを配置中..." -ForegroundColor Yellow

    $Links = @(
        @{
            Source = "$DotfilesDir\starship\starship.toml"
            Target = "$env:USERPROFILE\.config\starship.toml"
        },
        @{
            Source = "$DotfilesDir\vscode\settings.json"
            Target = "$env:APPDATA\Code\User\settings.json"
        },
        @{
            Source = "$DotfilesDir\powershell\Microsoft.PowerShell_profile.ps1"
            Target = $PROFILE
        }
    )

    foreach ($Link in $Links) {
        $TargetDir = Split-Path -Parent $Link.Target
        if (-not (Test-Path $TargetDir)) {
            New-Item -ItemType Directory -Path $TargetDir -Force | Out-Null
        }

        if (Test-Path $Link.Target) {
            $Existing = Get-Item $Link.Target -Force
            if ($Existing.LinkType -eq "SymbolicLink" -or $Existing.LinkType -eq "HardLink") {
                Write-Host "  既にリンク済み: $($Link.Target)" -ForegroundColor Green
                continue
            }
            # バックアップ
            $BackupPath = "$($Link.Target).backup"
            Move-Item -Path $Link.Target -Destination $BackupPath -Force
            Write-Host "  バックアップ: $BackupPath" -ForegroundColor DarkYellow
        }

        # 3段階フォールバック: SymbolicLink → HardLink → Copy
        $Linked = $false

        # 1. シンボリックリンクを試行（管理者権限 or 開発者モードが必要）
        try {
            New-Item -ItemType SymbolicLink -Path $Link.Target -Target $Link.Source -Force -ErrorAction Stop | Out-Null
            Write-Host "  シンボリックリンク: $($Link.Target) -> $($Link.Source)" -ForegroundColor Green
            $Linked = $true
        } catch {
            # 2. ハードリンクを試行（管理者権限不要、同一ドライブ・ファイルのみ）
            try {
                New-Item -ItemType HardLink -Path $Link.Target -Target $Link.Source -Force -ErrorAction Stop | Out-Null
                Write-Host "  ハードリンク: $($Link.Target) -> $($Link.Source)" -ForegroundColor Green
                $Linked = $true
            } catch {
                # 3. コピーにフォールバック
                Copy-Item -Path $Link.Source -Destination $Link.Target -Force
                Write-Host "  コピー: $($Link.Target) <- $($Link.Source)" -ForegroundColor Yellow
                Write-Host "    (リンク作成不可のため、コピーしました。更新時は再度 setup.ps1 を実行してください)" -ForegroundColor DarkYellow
                $Linked = $true
            }
        }
    }
}

Write-Host "`n=== セットアップ完了! ===" -ForegroundColor Cyan
Write-Host "VS Code を再起動してください (Ctrl+Shift+P -> Reload Window)`n"
