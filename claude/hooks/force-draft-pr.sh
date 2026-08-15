#!/bin/bash
# gh pr create に --draft が付いてなければ強制的に付与する PreToolUse hook

input=$(/bin/cat)
command=$(printf '%s' "$input" | jq -r '.tool_input.command // ""')

if printf '%s' "$command" | grep -qE '(^|[; &|])gh pr create\b' && ! printf '%s' "$command" | grep -qE -- '--draft\b'; then
  new_command=$(printf '%s' "$command" | sed -E 's/(gh pr create)/\1 --draft/')
  jq -n --arg cmd "$new_command" '{
    hookSpecificOutput: {
      hookEventName: "PreToolUse",
      updatedInput: { command: $cmd }
    }
  }'
else
  exit 0
fi
