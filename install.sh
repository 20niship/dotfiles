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

# Claude Code ステータスラインセットアップ
mkdir -p ~/.claude
rm -f ~/.claude/statusline-command.sh
ln -s $DOTFILES_DIR/claude/statusline-command.sh ~/.claude/statusline-command.sh

# Claude Code 通知スクリプト
rm -f ~/.claude/notify.sh
ln -s $DOTFILES_DIR/claude/notify.sh ~/.claude/notify.sh
chmod +x $DOTFILES_DIR/claude/notify.sh

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

