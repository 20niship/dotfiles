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

if command -v jq &> /dev/null; then
  jq '.statusLine = {
    "type": "command",
    "command": "bash '"$HOME"'/.claude/statusline-command.sh"
  }' ~/.claude/settings.json > ~/.claude/settings.json.tmp && mv ~/.claude/settings.json.tmp ~/.claude/settings.json

  # 通知フック設定をマージ (Stop / Notification)
  jq --slurpfile hooks "$DOTFILES_DIR/claude/hooks-notification.json" \
    '. * $hooks[0]' ~/.claude/settings.json > ~/.claude/settings.json.tmp \
    && mv ~/.claude/settings.json.tmp ~/.claude/settings.json

  # 権限設定をマージ (重複排除しながら allow リストをマージ)
  jq --slurpfile perms "$DOTFILES_DIR/claude/permissions.json" \
    '.permissions.allow = ((.permissions.allow // []) + $perms[0].permissions.allow | unique)' \
    ~/.claude/settings.json > ~/.claude/settings.json.tmp \
    && mv ~/.claude/settings.json.tmp ~/.claude/settings.json
else
  echo "警告: jq が見つかりません。~/.claude/settings.json に statusLine / hooks 設定を手動で追加してください"
fi

