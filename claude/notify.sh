#!/bin/bash
# Claude Code OS notification script
# Usage: echo '<hook JSON>' | bash ~/.claude/notify.sh [stop|notification]

MODE="${1:-notification}"
FOLDER=$(basename "$PWD")
TITLE="Claude Code [$FOLDER]"

if [ "$MODE" = "stop" ]; then
  cat > /dev/null  # consume stdin (unused for Stop hook)
  MSG="処理が完了しました"
else
  # Notification hook: stdin JSON contains {"message":"..."}
  INPUT=$(cat)
  RAW=$(printf '%s' "$INPUT" | jq -r '.message // ""' 2>/dev/null || true)
  if [ -n "$RAW" ]; then
    # 先頭150文字に収め、改行はスペースに変換
    MSG=$(printf '%s' "$RAW" | tr '\n' ' ' | cut -c1-150)
  else
    MSG="確認が必要です"
  fi
fi

# ダブルクォートをシングルに置換して各OSのコマンドで安全に使えるようにする
SAFE_MSG=$(printf '%s' "$MSG"   | tr '"' "'" | tr '\\' '/')
SAFE_TITLE=$(printf '%s' "$TITLE" | tr '"' "'" | tr '\\' '/')

OS=$(uname -s 2>/dev/null || echo "Windows")

case "$OS" in
  Darwin)
    # macOS: AppleScript 経由
    osascript -e "display notification \"$SAFE_MSG\" with title \"$SAFE_TITLE\"" \
      2>/dev/null || true
    ;;

  Linux)
    # Linux / Ubuntu / WSL
    notify-send "$SAFE_TITLE" "$SAFE_MSG" 2>/dev/null || true
    ;;

  MINGW*|MSYS*|CYGWIN*)
    # Windows + Git Bash / MSYS2:
    # 環境変数経由で PowerShell に渡すことで引用符問題を回避
    CLAUDE_NOTIFY_TITLE="$SAFE_TITLE" \
    CLAUDE_NOTIFY_MSG="$SAFE_MSG" \
    powershell.exe -NoProfile -Command "
      [void][Windows.UI.Notifications.ToastNotificationManager,Windows.UI.Notifications,ContentType=WindowsRuntime]
      \$t = [Windows.UI.Notifications.ToastNotificationManager]::GetTemplateContent(2)
      \$t.SelectSingleNode('//text[@id=1]').InnerText = \$env:CLAUDE_NOTIFY_TITLE
      \$t.SelectSingleNode('//text[@id=2]').InnerText = \$env:CLAUDE_NOTIFY_MSG
      \$n = [Windows.UI.Notifications.ToastNotificationManager]::CreateToastNotifier('Claude Code')
      \$n.Show([Windows.UI.Notifications.ToastNotification]::new(\$t))
    " 2>/dev/null || true
    ;;
esac
