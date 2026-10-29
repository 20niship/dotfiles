# UsageBar (macOS)

Claude Code と Codex のサブスクリプション使用率を macOS のメニューバーに表示します。`C` は Claude、`X` は Codex、`5h` は 5 時間枠、`W` は週間枠です。数字は使用率で、緑は 70% 未満、橙は 70% 以上、赤は 90% 以上を表します。クリックするとリセット日時、取得エラー、更新ボタンが見られます。5 分ごとに自動更新します。

## ビルド・起動

macOS、Xcode Command Line Tools、Claude Code と Codex CLI のログインが必要です。

```sh
bash usagebar/install.sh
```

`~/Applications/UsageBar.app` にインストールし、LaunchAgent で現在のセッションと次回ログイン時に起動します。単発で試す場合は `bash usagebar/build.sh` の後に `open usagebar/dist/UsageBar.app` を実行してください。

macOS 以外で `build.sh` や `install.sh` を実行した場合は何も変更せず終了します。リポジトリの通常の `install.sh` からは UsageBar を実行しません。

Claude の使用率は Claude Code が保存した macOS キーチェーンの認証情報で Anthropic の使用量エンドポイントから読み取ります。Codex は公式 CLI の `account/rateLimits/read` を使います。トークンは保存・表示しません。契約によって 5 時間枠が提供されない場合、その欄は `—` になります。Claude の使用量エンドポイントは非公開 API のため、仕様変更やレート制限で取得できなくなる場合があります。
