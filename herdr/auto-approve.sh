#!/bin/bash
# claude / codex が blocked (許可待ち) のとき、画面が yes/no 系の許可質問なら Enter (=既定の Yes) を送る常駐スクリプト
# 無効化: launchctl bootout gui/$(id -u) ~/Library/LaunchAgents/dev.herdr.auto-approve.plist
# ponytail: 1秒ポーリング。events.subscribe は pane_id 必須で全ペイン購読できないため。

export PATH="$HOME/.local/bin:$PATH"

while true; do
  herdr agent list 2>/dev/null \
    | jq -r '.result.agents[]? | select(.agent_status=="blocked" and (.agent=="claude" or .agent=="codex")) | .pane_id' \
    | while IFS= read -r pane; do
        screen=$(herdr pane read "$pane" --source visible 2>/dev/null)
        # Yes が既定選択の質問のみ対象 (claude: "❯ 1. Yes" / codex: "Yes, proceed")
        if echo "$screen" | grep -qE '❯ *1\. *Yes|›.*Yes, (proceed|continue)'; then
          herdr agent send-keys "$pane" enter >/dev/null 2>&1
        fi
      done
  sleep 1
done
