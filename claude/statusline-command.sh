#!/bin/bash
# Claude Code ステータスライン表示スクリプト

input=$(cat)

# --- Gitブランチ名 ---
branch=$(git -C "$(echo "$input" | jq -r '.workspace.current_dir')" --no-optional-locks branch --show-current 2>/dev/null)

# --- Gitの変更統計 (追加/削除行数) ---
diff_stat=""
if [ -n "$branch" ]; then
  diff_out=$(git -C "$(echo "$input" | jq -r '.workspace.current_dir')" --no-optional-locks diff --shortstat 2>/dev/null)
  if [ -n "$diff_out" ]; then
    ins=$(echo "$diff_out" | grep -o '[0-9]* insertion' | grep -o '[0-9]*')
    del=$(echo "$diff_out" | grep -o '[0-9]* deletion' | grep -o '[0-9]*')
    ins=${ins:-0}
    del=${del:-0}
    diff_stat="+${ins}/-${del}"
  else
    diff_stat="clean"
  fi
fi

# --- フォルダ名 ---
current_dir=$(echo "$input" | jq -r '.workspace.current_dir // empty')
folder_name=$(basename "$current_dir")

# --- コンテキスト使用率 ---
remaining=$(echo "$input" | jq -r '.context_window.remaining_percentage // empty')
used=$(echo "$input" | jq -r '.context_window.used_percentage // empty')
input_tokens=$(echo "$input" | jq -r '.context_window.current_usage.input_tokens // empty')
ctx_window_size=$(echo "$input" | jq -r '.context_window.context_window_size // empty')

# --- 使用中のモデル ---
model=$(echo "$input" | jq -r '.model.display_name // .model.id // "unknown"')

# --- 応答時間の推定 (トークン数 / ~100 tok/s) ---
out_tokens=$(echo "$input" | jq -r '.context_window.current_usage.output_tokens // empty')
resp_time=""
if [ -n "$out_tokens" ] && [ "$out_tokens" -gt 0 ] 2>/dev/null; then
  secs=$(( out_tokens / 100 ))
  if [ "$secs" -ge 1 ]; then
    resp_time="${secs}s"
  else
    resp_time="<1s"
  fi
fi

# --- 出力の構築 ---
# カラーコード (ANSI)
CYAN='\033[36m'
GREEN='\033[32m'
YELLOW='\033[33m'
RED='\033[31m'
BLUE='\033[34m'
RESET='\033[0m'
DIM='\033[2m'
BOLD='\033[1m'
BRIGHT_WHITE='\033[97m'
SEP="${DIM} | ${RESET}"

parts=()

# フォルダ名
if [ -n "$folder_name" ]; then
  parts+=("${BOLD}${BRIGHT_WHITE} ${folder_name}${RESET}")
fi

# ブランチ
if [ -n "$branch" ]; then
  parts+=("${CYAN} ${branch}${RESET}")
fi

# 変更状況
if [ -n "$diff_stat" ]; then
  if [ "$diff_stat" = "clean" ]; then
    parts+=("${GREEN}~ clean${RESET}")
  else
    parts+=("${YELLOW}~ ${diff_stat}${RESET}")
  fi
fi

# コンテキスト
if [ -n "$remaining" ]; then
  remaining_int=${remaining%.*}
  if [ "${remaining_int:-100}" -le 20 ]; then
    ctx_color="$RED"
  elif [ "${remaining_int:-100}" -le 50 ]; then
    ctx_color="$YELLOW"
  else
    ctx_color="$GREEN"
  fi
  used_disp=$(printf "%.0f" "${used:-0}" 2>/dev/null || echo "${used:-0}")
  # トークン数をK単位で表示
  if [ -n "$input_tokens" ] && [ -n "$ctx_window_size" ]; then
    used_k=$(( input_tokens / 1000 ))
    max_k=$(( ctx_window_size / 1000 ))
    parts+=("${ctx_color}ctx ${used_disp}% (${used_k}k/${max_k}k)${RESET}")
  else
    parts+=("${ctx_color}ctx ${used_disp}% used${RESET}")
  fi
fi

# モデル名
if [ -n "$model" ] && [ "$model" != "unknown" ]; then
  parts+=("${BLUE}${model}${RESET}")
fi

# 応答時間
if [ -n "$resp_time" ]; then
  parts+=("${DIM}~${resp_time}${RESET}")
fi

# 各要素を区切り文字で結合
result=""
for part in "${parts[@]}"; do
  if [ -z "$result" ]; then
    result="$part"
  else
    result="${result}${SEP}${part}"
  fi
done

printf "%b" "$result"
