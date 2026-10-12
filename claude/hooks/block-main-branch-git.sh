#!/bin/bash
# main/master/developへ直接git add/commit/pushしてしまう事故を防ぐ(過去に誤って直接pushした反省から)

PY=$(command -v python3 || command -v python)
[ -z "$PY" ] && exit 0

payload=$(cat)
command=$(printf '%s' "$payload" | "$PY" -c 'import json,sys; print(json.load(sys.stdin).get("tool_input",{}).get("command",""))' 2>/dev/null)
[ -z "$command" ] && exit 0

if ! printf '%s' "$command" | grep -qE '(^|[;&|]) *git +(add|commit|push)( |$)'; then
  exit 0
fi

cd "${CLAUDE_PROJECT_DIR:-$(git rev-parse --show-toplevel 2>/dev/null)}" 2>/dev/null || exit 0
branch=$(git branch --show-current 2>/dev/null)

case "$branch" in
  main|master|develop)
    BLOCKED_BRANCH="$branch" "$PY" -c '
import json, os, sys
branch = os.environ["BLOCKED_BRANCH"]
json.dump({
    "hookSpecificOutput": {
        "hookEventName": "PreToolUse",
        "permissionDecision": "deny",
        "permissionDecisionReason": f"ブランチ \"{branch}\" 上でのgit add/commit/pushはブロックされています。先にフィーチャーブランチを作成してください(例: git checkout -b feature/xxx)。",
    }
}, sys.stdout)
'
    ;;
esac
exit 0
