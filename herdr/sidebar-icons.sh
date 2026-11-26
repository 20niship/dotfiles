#!/bin/bash
# エージェント種別のアイコンと、末尾のディレクトリ名を除いた作業タイトルを報告する。

export PATH="$HOME/.local/bin:$PATH"

while true; do
  agents=$(herdr agent list 2>/dev/null)
  if [ -n "$agents" ]; then
    while IFS=$'\t' read -r pane agent title; do
      case "$agent" in
        claude) icon='✳' ;;
        codex) icon='⬡' ;;
        *) icon='◇' ;;
      esac
      args=(--source user:sidebar-icons --token "agent_icon=$icon")
      if [ -n "$title" ]; then
        args+=(--token "task_title=$title")
      else
        args+=(--clear-token task_title)
      fi
      herdr pane report-metadata "$pane" "${args[@]}" >/dev/null 2>&1
    done < <(jq -r '
      .result.agents[]? |
      (.cwd // "" | split("/") | last) as $dir |
      (.terminal_title_stripped // "") as $title |
      [$title, " | " + $dir] as $parts |
      [.pane_id, .agent,
       (if $dir != "" and ($title | endswith($parts[1]))
        then $title[0:-($parts[1] | length)]
        else $title end)] | @tsv
    ' <<< "$agents")
  fi
  sleep 15
done
