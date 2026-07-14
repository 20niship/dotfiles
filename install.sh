# dotfilesをホームディレクトリにリンクする

# current dir
DOTFILES_DIR=$(cd $(dirname $0); pwd)

for file in .zshrc .gitignore .tmux.conf .clang-format .bashrc .wezterm.lua
do
  rm -rf $HOME/$file
  ln -s $DOTFILES_DIR/$file $HOME/$file
done

mkdir -p ~/.config/nvim
rm -rf ~/.config/nvim/init.vim
ln -s $DOTFILES_DIR/init.vim ~/.config/nvim/init.vim

# herdr 設定ファイル
mkdir -p ~/.config/herdr
rm -f ~/.config/herdr/config.toml
ln -s $DOTFILES_DIR/herdr/config.toml ~/.config/herdr/config.toml

# herdr サーバーが起動中なら設定を自動反映する
if command -v herdr >/dev/null 2>&1 && herdr status server >/dev/null 2>&1; then
  herdr server reload-config >/dev/null 2>&1
fi

# herdr の新規タブ自動リネームスクリプトを LaunchAgent として登録する
chmod +x $DOTFILES_DIR/herdr/auto-rename-tabs.sh
mkdir -p ~/Library/LaunchAgents
PLIST=~/Library/LaunchAgents/dev.herdr.auto-rename-tabs.plist
cat > $PLIST <<PLIST_EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>Label</key>
  <string>dev.herdr.auto-rename-tabs</string>
  <key>ProgramArguments</key>
  <array>
    <string>/bin/bash</string>
    <string>$DOTFILES_DIR/herdr/auto-rename-tabs.sh</string>
  </array>
  <key>RunAtLoad</key>
  <true/>
  <key>KeepAlive</key>
  <true/>
  <key>StandardOutPath</key>
  <string>$HOME/.config/herdr/auto-rename-tabs.log</string>
  <key>StandardErrorPath</key>
  <string>$HOME/.config/herdr/auto-rename-tabs.log</string>
</dict>
</plist>
PLIST_EOF

launchctl bootout gui/$(id -u) $PLIST >/dev/null 2>&1
launchctl bootstrap gui/$(id -u) $PLIST >/dev/null 2>&1

# Claude Code ステータスラインセットアップ
mkdir -p ~/.claude
rm -f ~/.claude/statusline-command.sh
ln -s $DOTFILES_DIR/claude/statusline-command.sh ~/.claude/statusline-command.sh

# Claude Code 通知スクリプト
rm -f ~/.claude/notify.sh
ln -s $DOTFILES_DIR/claude/notify.sh ~/.claude/notify.sh
chmod +x $DOTFILES_DIR/claude/notify.sh

# Claude Code CLAUDE.md
rm -f ~/.claude/CLAUDE.md
ln -s $DOTFILES_DIR/claude/CLAUDE.md ~/.claude/CLAUDE.md

# ステータスライン設定を settings.json にマージ
if ! [ -f ~/.claude/settings.json ]; then
  echo '{}' > ~/.claude/settings.json
fi

python3 -c "
import json, sys

settings_path = '$HOME/.claude/settings.json'
hooks_path = '$DOTFILES_DIR/claude/hooks-notification.json'
perms_path = '$DOTFILES_DIR/claude/permissions.json'

with open(settings_path) as f:
    settings = json.load(f)

# statusLine 設定
settings['statusLine'] = {
    'type': 'command',
    'command': 'bash $HOME/.claude/statusline-command.sh'
}

# 通知フック設定をマージ (deep merge)
with open(hooks_path) as f:
    hooks = json.load(f)
for key, val in hooks.items():
    if key in settings and isinstance(settings[key], dict) and isinstance(val, dict):
        settings[key].update(val)
    else:
        settings[key] = val

# 権限設定をマージ (重複排除しながら allow リストをマージ)
with open(perms_path) as f:
    perms = json.load(f)
existing_allow = settings.get('permissions', {}).get('allow', [])
new_allow = perms.get('permissions', {}).get('allow', [])
merged = sorted(set(existing_allow + new_allow))
settings.setdefault('permissions', {})['allow'] = merged

with open(settings_path, 'w') as f:
    json.dump(settings, f, indent=2, ensure_ascii=False)
    f.write('\n')
"

