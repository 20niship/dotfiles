#!/bin/bash
# gh pr create に --draft が付いてなければ強制的に付与する(jq非依存、python/python3自動検出)

PY=$(command -v python3 || command -v python)
[ -z "$PY" ] && exit 0

exec "$PY" -c '
import json
import re
import sys

payload = json.load(sys.stdin)
command = payload.get("tool_input", {}).get("command", "")

if re.search(r"(^|[; &|])gh pr create\b", command) and not re.search(r"--draft\b", command):
    new_command = re.sub(r"(gh pr create)", r"\1 --draft", command, count=1)
    json.dump(
        {
            "hookSpecificOutput": {
                "hookEventName": "PreToolUse",
                "updatedInput": {"command": new_command},
            }
        },
        sys.stdout,
    )
'
