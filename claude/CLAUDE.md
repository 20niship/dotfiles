# ルール

- git commit, git push, PR作成などでcatを使う際は、catがbatのaliasの可能性があるため、`/bin/cat`を明示的に使用すること。ヒアドキュメント(`$(cat <<'EOF'...EOF)`)の場合も同様に`$(/bin/cat <<'EOF'...EOF)`とすること
- コミットやコメントなどは基本的に日本語で行うこと。会話中の結論も日本語で示すこと
- rm はtrashコマンドへのaliasなので, /bin/rmを明示的に使用すること
