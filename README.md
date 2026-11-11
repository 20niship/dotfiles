# Linux environment example

## 対話式キャッシュ掃除

`.zshrc` を読み込んだ後に `cache-clean` を実行する。macOS と Ubuntu で Python 3 の標準ライブラリだけを使用する。

```sh
cache-clean                 # TUI で候補を複数選択して実行
cache-clean --list          # TUI で閲覧だけ
cache-clean --min-mib 1000 --older-days 60
cache-clean --min-item-mib 0 # 1 MiB 以下の候補も表示
```

起動直後から色付きの TUI を表示し、ディスクの合計・使用・空き容量と使用率、チェック中の既知の削除対象容量を表示する。Tab で `~/Desktop` と `~/Downloads` の直下フォルダごとの使用量・ディスク全体に対する割合を表示する。フォルダサイズと候補は画面を表示したまま計測し、候補は約0.2秒ごとに更新する。探索中でも表示済みの候補を選んで実行でき、その場合は残りの探索を止める。repo 内のグループ合計、Git object 総量、フォルダ使用量が 1 MiB 以下の項目は既定では表示しない。

`~/Desktop` 以下の Git リポジトリと worktree を再帰的に探し、`.venv`、CMake/Meson/Ninja の `build*`、Python/Node/Rust の再生成可能なディレクトリ、submodule を除くリポジトリの `git gc` を候補にする。同じ repo の `build*` や Python キャッシュは種類ごとに1項目へまとめ、`i` で内訳を確認できる。`.venv`、`node_modules`、`git gc` は既定でチェック済み。Docker の未使用 image、container、network、volume、build cache、および `~/Downloads` 直下の 500 MiB 以上かつ更新から 30 日以上のファイルも表示する。Space でチェック、矢印または `j`/`k` で移動、`/` で候補を絞り込み、Enter で「実行へ」、`y` で確定する。`a` は検索結果に関係なく全候補のチェックを一括で付け、もう一度押すと全件解除する。探索中に追加される候補にも適用する。`n` は表示中の候補だけを解除する。処理中と完了後も TUI で進捗と結果を表示する。Git の表示サイズは object 総量であり、回収可能量ではない。選択容量の合計にも Git の object 総量は含めず別表示する。Docker volume は未使用の named volume も対象になるので、これも既定では未選択。


## install:


## config files

- nvim = `config/init.vim`
- zsh  = `config/.zshrc`
- tmux = `confif/.tmux.conf`


## 各種ソフトウェア
- vscode
  -  https://code.visualstudio.com/download
-  nodejs
  -  https://nodejs.org/ja/download/
-  cmake
  -  https://cmake.org/download/
- opencv
  - https://qiita.com/tetsu_koba/items/7487fc5fa258f683122b

## visudoとかで実行されるEditorを変更
```
sudo update-alternatives --config editor
```
を実行して、Editorの番号を選択

## 文字化け（ダイヤになるやつ）対策
`apt-get install language-pack-ja-base language-pack-ja`　を実行し、

以下をbashrcとかに追記
```sh
case $TERM in
    linux) LANG=C ;;
    *) LANG=ja_JP.UTF-8 ;;
esac
```

## デフォルトでZsh起動
```
chsh -s $(which zsh)
```

現在のシェルは`echo $SHELL`で確認できる

`.bashrc`に`exec zsh`と書くことでも対応Ok


## Tips
- PythonのOpenCVを使おうとした時に、libGL.soが見つかりませんとか言われる
  - `$ apt-get install libopencv-dev`



