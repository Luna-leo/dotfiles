# dotfiles

Windows 開発環境の設定ファイル集。Tokyo Night テーマで統一したモダンな見た目。

## 含まれる設定

| ファイル | 内容 |
|---------|------|
| `starship/starship.toml` | Starship プロンプト (Tokyo Night プリセット) |
| `vscode/settings.json` | VS Code 設定 (テーマ, フォント, ミニマルUI, 透過) |
| `vscode/keybindings.json` | VS Code キーバインド (テーマ切替: `Ctrl+Alt+T`) |
| `powershell/Microsoft.PowerShell_profile.ps1` | PowerShell プロファイル |
| `windows-terminal/settings.json` | Windows Terminal 設定 (フォント, キーバインド) |

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
- VS Code 拡張機能のインストール (Tokyo Night, Catppuccin Icons, Error Lens 等)
- 設定ファイルの配置 (リンクまたはコピー)

### オプション

```powershell
# インストールをスキップ (リンクのみ作成)
.\setup.ps1 -SkipInstall

# リンク作成をスキップ (インストールのみ)
.\setup.ps1 -SkipSymlinks
```

## テーマ

**Tokyo Night** をベースに Dark / Light 切替対応:
- VS Code: Tokyo Night (Dark) ⇔ Tokyo Night Light (`Ctrl+Alt+T` で切替)
- OS のダーク/ライトモードにも自動連動
- アイコン: Catppuccin (Mocha / Latte を自動切替)
- Starship プロンプト: Tokyo Night スタイル
- フォント: UDEV Gothic 35NFLG (日本語 + Nerd Font + リガチャ)
- 透け感: Glassit で半透明ウィンドウ効果 (`Ctrl+Alt+Z/C` で調整)
