# dotfiles

Windows 開発環境の設定ファイル集。Catppuccin Mocha テーマで統一したモダンな見た目。

## 含まれる設定

| ファイル | 内容 |
|---------|------|
| `starship/starship.toml` | Starship プロンプト (Catppuccin Mocha グラデーション) |
| `vscode/settings.json` | VS Code 設定 (テーマ, フォント, ミニマルUI) |
| `powershell/Microsoft.PowerShell_profile.ps1` | PowerShell プロファイル |

## セットアップ

### 1. リポジトリをクローン

```powershell
git clone https://github.com/yourname/dotfiles.git ~/dotfiles
```

### 2. セットアップスクリプトを実行

```powershell
cd ~/dotfiles
.\setup.ps1
```

> **管理者権限は不要です。** 設定ファイルの配置はシンボリックリンク → ハードリンク → コピーの順にフォールバックします。

以下が自動で行われます:
- Starship のインストール (ユーザースコープ)
- UDEV Gothic 35NFLG フォントのダウンロード・インストール
- VS Code 拡張機能のインストール (Catppuccin, Error Lens 等)
- 設定ファイルの配置 (リンクまたはコピー)

### オプション

```powershell
# インストールをスキップ (リンクのみ作成)
.\setup.ps1 -SkipInstall

# リンク作成をスキップ (インストールのみ)
.\setup.ps1 -SkipSymlinks
```

## テーマ

**Catppuccin Mocha** を全ツールで統一:
- VS Code エディタ + アイコン
- Starship プロンプト (グラデーション表示)
- フォント: UDEV Gothic 35NFLG (日本語 + Nerd Font + リガチャ)
