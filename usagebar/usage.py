#!/usr/bin/env python3
"""Read Claude and Codex subscription windows without saving credentials."""

import json
import os
import selectors
import shutil
import subprocess
import sys
import time
import urllib.error
import urllib.request
from concurrent.futures import ThreadPoolExecutor


def window(data, percent_key, reset_key):
    if not isinstance(data, dict) or data.get(percent_key) is None:
        return None
    return {"used": max(0, min(100, float(data[percent_key]))), "reset": data.get(reset_key)}


def claude_token():
    credential = None
    if sys.platform == "darwin":
        try:
            result = subprocess.run(
                ["/usr/bin/security", "find-generic-password", "-a", os.environ.get("USER", ""),
                 "-s", "Claude Code-credentials", "-w"],
                capture_output=True, text=True, timeout=8, check=True,
            )
            credential = json.loads(result.stdout)
        except (subprocess.SubprocessError, ValueError):
            pass
    if credential is None:
        path = os.path.expanduser("~/.claude/.credentials.json")
        try:
            with open(path, encoding="utf-8") as file:
                credential = json.load(file)
        except (OSError, ValueError):
            return None
    return credential.get("claudeAiOauth", {}).get("accessToken")


def claude():
    token = claude_token()
    if not token:
        return {"error": "Claude Code のログイン情報が見つかりません"}
    request = urllib.request.Request(
        "https://api.anthropic.com/api/oauth/usage",
        headers={"Authorization": "Bearer " + token, "anthropic-beta": "oauth-2025-04-20",
                 "User-Agent": "usagebar/1.0"},
    )
    try:
        with urllib.request.urlopen(request, timeout=12) as response:
            data = json.load(response)
    except urllib.error.HTTPError as error:
        return {"error": f"Claude 使用量 API: HTTP {error.code}"}
    except (urllib.error.URLError, TimeoutError, ValueError) as error:
        return {"error": f"Claude 使用量の取得に失敗: {type(error).__name__}"}
    return {
        "fiveHour": window(data.get("five_hour"), "utilization", "resets_at"),
        "weekly": window(data.get("seven_day"), "utilization", "resets_at"),
    }


def codex():
    executable = shutil.which("codex") or os.path.expanduser("~/.local/bin/codex")
    if not os.path.isfile(executable):
        return {"error": "Codex CLI が見つかりません"}
    process = None
    try:
        process = subprocess.Popen(
            [executable, "app-server"], stdin=subprocess.PIPE, stdout=subprocess.PIPE,
            stderr=subprocess.DEVNULL, text=True, bufsize=1,
        )
        selector = selectors.DefaultSelector()
        selector.register(process.stdout, selectors.EVENT_READ)

        def send(message):
            process.stdin.write(json.dumps(message) + "\n")
            process.stdin.flush()

        def receive(request_id):
            deadline = time.monotonic() + 15
            while time.monotonic() < deadline:
                if not selector.select(max(0, deadline - time.monotonic())):
                    break
                line = process.stdout.readline()
                if not line:
                    break
                message = json.loads(line)
                if message.get("id") == request_id:
                    return message
            raise TimeoutError("Codex CLI の応答がありません")

        send({"id": 1, "method": "initialize", "params": {
            "clientInfo": {"name": "usagebar", "version": "1.0"}}})
        initial = receive(1)
        if "error" in initial:
            raise RuntimeError("Codex CLI の初期化に失敗")
        send({"method": "initialized"})
        send({"id": 2, "method": "account/rateLimits/read"})
        response = receive(2)
        if "error" in response:
            raise RuntimeError("Codex にログインしてください")
        result = response.get("result", {})
        limits = result.get("rateLimits") or result.get("rateLimitsByLimitId", {}).get("codex") or {}
        windows = {"fiveHour": None, "weekly": None}
        for slot in ("primary", "secondary"):
            item = limits.get(slot)
            if not isinstance(item, dict):
                continue
            minutes = item.get("windowDurationMins")
            if minutes == 300:
                windows["fiveHour"] = window(item, "usedPercent", "resetsAt")
            elif minutes == 10080:
                windows["weekly"] = window(item, "usedPercent", "resetsAt")
        return windows
    except (OSError, ValueError, RuntimeError, TimeoutError, BrokenPipeError) as error:
        return {"error": str(error)}
    finally:
        if process is not None:
            process.terminate()
            try:
                process.wait(timeout=2)
            except subprocess.TimeoutExpired:
                process.kill()
                process.wait()


def main():
    with ThreadPoolExecutor(max_workers=2) as pool:
        claude_future = pool.submit(claude)
        codex_future = pool.submit(codex)
        print(json.dumps({"claude": claude_future.result(), "codex": codex_future.result(),
                          "fetchedAt": time.time()}))


if __name__ == "__main__":
    main()
