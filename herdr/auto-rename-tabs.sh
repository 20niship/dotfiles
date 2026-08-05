#!/bin/bash
# 新規タブを、その1枚目のペインが開いているディレクトリ名で自動的にリネームする常駐スクリプト
# herdr の socket API (events.subscribe) で pane_created イベントを購読して実現する

export PATH="$HOME/.local/bin:$PATH"
SOCK="$HOME/.config/herdr/herdr.sock"

while true; do
  if [ ! -S "$SOCK" ]; then
    sleep 5
    continue
  fi

  {
    echo '{"id":"auto-rename-tabs","method":"events.subscribe","params":{"subscriptions":[{"type":"pane.created"}]}}'
    # 接続を張ったままにしておくためのダミー入力
    while true; do sleep 3600; done
  } | nc -U "$SOCK" | while IFS= read -r line; do
    [ "$(echo "$line" | jq -r '.event // empty')" = "pane_created" ] || continue

    tab_id=$(echo "$line" | jq -r '.data.pane.tab_id // empty')
    cwd=$(echo "$line" | jq -r '.data.pane.cwd // empty')
    [ -n "$tab_id" ] && [ -n "$cwd" ] || continue

    tab_info=$(herdr tab get "$tab_id" 2>/dev/null)
    pane_count=$(echo "$tab_info" | jq -r '.result.tab.pane_count // 0')
    label=$(echo "$tab_info" | jq -r '.result.tab.label // ""')

    # 新規タブの1枚目のペインで、ラベルがまだ既定 (数字のみ/空) の場合だけ自動命名する
    if [ "$pane_count" = "1" ] && [[ "$label" =~ ^[0-9]*$ ]]; then
      herdr tab rename "$tab_id" "$(basename "$cwd")" >/dev/null 2>&1
    fi
  done

  sleep 2
done
