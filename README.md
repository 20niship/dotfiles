# Linux environment example


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



