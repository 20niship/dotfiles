# ----------------------------
# Lang
# -----------------------------
export LANG=ja_JP.UTF-8
export LESSCHARSET=utf-8

# -----------------------------
# General
# -----------------------------
# 色を使用
autoload -Uz colors ; colors

# エディタをvimに設定
export EDITOR=nvim
# sudoeditコマンドでファイル編集するときのエディタを設定
export SUDO_EDITOR=nvim

# Ctrl+Dでログアウトしてしまうことを防ぐ
#setopt IGNOREEOF

# パスを追加したい場合
export PATH="$HOME/bin:$PATH"

# cdした際のディレクトリをディレクトリスタックへ自動追加
setopt auto_pushd

# ディレクトリスタックへの追加の際に重複させない
setopt pushd_ignore_dups

# emacsキーバインド
bindkey -e

# viキーバインド
#bindkey -v

# フローコントロールを無効にする
setopt no_flow_control

# ワイルドカード展開を使用する
setopt extended_glob

# cdコマンドを省略して、ディレクトリ名のみの入力で移動
setopt auto_cd

# コマンドラインがどのように展開され実行されたかを表示するようになる
#setopt xtrace

# 自動でpushdを実行
setopt auto_pushd

# pushdから重複を削除
setopt pushd_ignore_dups

# ビープ音を鳴らさないようにする
#setopt no_beep

# カッコの対応などを自動的に補完する
setopt auto_param_keys

# ディレクトリ名の入力のみで移動する
setopt auto_cd

# bgプロセスの状態変化を即時に知らせる
setopt notify

# 8bit文字を有効にする
setopt print_eight_bit

# 終了ステータスが0以外の場合にステータスを表示する
setopt print_exit_value

# ファイル名の展開でディレクトリにマッチした場合 末尾に / を付加
setopt mark_dirs

# コマンドのスペルチェックをする
setopt correct

# コマンドライン全てのスペルチェックをする
setopt correct_all

# 上書きリダイレクトの禁止
setopt no_clobber

# sudo の後ろでコマンド名を補完する
zstyle ':completion:*:sudo:*' command-path /usr/local/sbin /usr/local/bin \
                   /usr/sbin /usr/bin /sbin /bin /usr/X11R6/bin

# ps コマンドのプロセス名補完
zstyle ':completion:*:processes' command 'ps x -o pid,s,args'

# パスの最後のスラッシュを削除しない
setopt noautoremoveslash

# 各コマンドが実行されるときにパスをハッシュに入れる
#setopt hash_cmds

# rsysncでsshを使用する
export RSYNC_RSH=ssh

# その他
umask 022
ulimit -c 0

# -----------------------------
# Prompt
# -----------------------------
# %M    ホスト名
# %m    ホスト名
# %d    カレントディレクトリ(フルパス)
# %~    カレントディレクトリ(フルパス2)
# %C    カレントディレクトリ(相対パス)
# %c    カレントディレクトリ(相対パス)
# %n    ユーザ名
# %#    ユーザ種別
# %?    直前のコマンドの戻り値
# %D    日付(yy-mm-dd)
# %W    日付(yy/mm/dd)
# %w    日付(day dd)
# %*    時間(hh:flag_mm:ss)
# %T    時間(hh:mm)
# %t    時間(hh:mm(am/pm))
PROMPT='%F{cyan}%n@%m%f:%~# '

# -----------------------------
# Completion
# -----------------------------
# 自動補完を有効にする
autoload -Uz compinit ; compinit

# 単語の入力途中でもTab補完を有効化
#setopt complete_in_word

# コマンドミスを修正
setopt correct

# 補完の選択を楽にする
zstyle ':completion:*' menu select

# 補完候補をできるだけ詰めて表示する
setopt list_packed

# 補完候補にファイルの種類も表示する
#setopt list_types

# 色の設定
export LSCOLORS=Exfxcxdxbxegedabagacad

# 補完時の色設定
export LS_COLORS='di=01;34:ln=01;35:so=01;32:ex=01;31:bd=46;34:cd=43;34:su=41;30:sg=46;30:tw=42;30:ow=43;30'

# キャッシュの利用による補完の高速化
zstyle ':completion::complete:*' use-cache true

# 補完候補に色つける
autoload -U colors ; colors ; zstyle ':completion:*' list-colors "${LS_COLORS}"
#zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}

# 大文字・小文字を区別しない(大文字を入力した場合は区別する)
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}'

# manの補完をセクション番号別に表示させる
zstyle ':completion:*:manuals' separate-sections true

# --prefix=/usr などの = 以降でも補完
setopt magic_equal_subst

# -----------------------------
# History
# -----------------------------
# 基本設定
HISTFILE=$HOME/.zsh-history
HISTSIZE=1000
SAVEHIST=10000

# ヒストリーに重複を表示しない
setopt histignorealldups

# 他のターミナルとヒストリーを共有
setopt share_history

# すでにhistoryにあるコマンドは残さない
setopt hist_ignore_all_dups

# historyに日付を表示

# ヒストリに保存するときに余分なスペースを削除する
setopt hist_reduce_blanks

# 履歴をすぐに追加する
setopt inc_append_history

# ヒストリを呼び出してから実行する間に一旦編集できる状態になる
# setopt hist_verify

#余分なスペースを削除してヒストリに記録する
#setopt hist_reduce_blanks

# historyコマンドは残さない
#setopt hist_save_no_dups

# ^R で履歴検索をするときに * でワイルドカードを使用出来るようにする
#bindkey '^R' history-incremental-pattern-search-backward
#bindkey "^S" history-incremental-search-forward

# ^P,^Nを検索へ割り当て
#bindkey "^P" history-beginning-search-backward-end
#bindkey "^N" history-beginning-search-forward-end

# -----------------------------
# Alias
# -----------------------------
# グローバルエイリアス
# alias -g L='| less'
# alias -g H='| head'
# alias -g G='| grep'
# alias -g GI='| grep -ri'


# check lsd command available
if type lsd >/dev/null 2>&1; then
  alias ls='lsd'
  alias l='lsd'
  alias ll='lsd -l'
  alias la='lsd -a'
  alias lla='lsd -la'
  alias lt='lsd --tree'
  alias llt='lsd -l --tree'
  alias lta='lsd -a --tree'
  alias llta='lsd -la --tree'
else
  alias ls='ls --color=auto'
  alias l='ls --color=auto'
  alias ll='ls -l --color=auto'
  alias la='ls -la --color=auto'
  alias lla='ls -la --color=auto'
  alias lt='tree'
  alias llt='tree -l'
  alias lta='tree -a'
  alias llta='tree -la'
fi

# catにシンタックスハイライトする
# sudo apt install bat
# https://github.com/sharkdp/bat/blob/master/README.md#installation
alias cat='batcat -p --color=always'

alias df="df -Th"
alias su="su -l"
alias so='source'
alias vi='nvim'
alias v='nvim'
alias vim='nvim'

# alias vz='vim ~/.zshrc'
# alias cp='cp -i'
# alias rm='rm -i'
alias mkdir='mkdir -p'
alias ..='cd ../'
alias back='pushd'
alias py='python3'

# alias tma='tmux attach'
# alias tml='tmux list-window'

alias dki="docker run -i -t -P"
alias dex="docker exec -i -t"
alias drmf='docker stop $(docker ps -a -q) && docker rm $(docker ps -a -q)'

alias c="clear"
alias n='ninja'
alias sgl='git log --graph --oneline --branches --decorate=full -20 --date=short --format="%C(yellow)%h%C(reset) %C(magenta)[%ad]%C(reset)%C(auto)%d%C(reset) %s %C(cyan)@%an%C(reset)"'

alias make='make -j$(nproc)'

alias h='fc -lt '%F %T' 1'

if [[ -x `which colordiff` ]]; then
  alias diff='colordiff -u'
else
  alias diff='diff -u'
fi

function t()
{
  tmux new-session -s $(pwd |sed -E 's!^.+/([^/]+/[^/]+)$!\1!g' | sed -e 's/\./-/g')
}


# -----------------------------
# Plugin
# -----------------------------
# zplugが無ければインストール
if [[ ! -d ~/.zplug ]];then
  git clone https://github.com/zplug/zplug ~/.zplug
fi

# zplugを有効化する
source ~/.zplug/init.zsh

# プラグインList
# zplug "ユーザー名/リポジトリ名", タグ
zplug "zsh-users/zsh-completions"
zplug "zsh-users/zsh-autosuggestions"
zplug "zsh-users/zsh-syntax-highlighting", defer:2
zplug "romkatv/powerlevel10k", use:powerlevel10k.zsh-theme, from:github, as:theme
# zplug "junegunn/fzf", from:gh-r, as:command, rename-to:fzf

# インストールしていないプラグインをインストール
if ! zplug check --verbose; then
  printf "Install? [y/N]: "
  if read -q; then
      echo; zplug install
  fi
fi

# コマンドをリンクして、PATH に追加し、プラグインは読み込む
# zplug load --verbose
zplug load
# if failed, re-install by `zplug install`

# -----------------------------
# PATH
# -----------------------------
case "${OSTYPE}" in
  darwin*)
    export PATH=/opt/local/bin:/opt/local/sbin:$PATH
    export MANPATH=/opt/local/share/man:/opt/local/man:$MANPATH
  ;;
esac

# -----------------------------
# Python
# -----------------------------
export PYENV_ROOT="$HOME/.pyenv"
export PATH="$PYENV_ROOT/bin:$HOME/:$PATH"
#eval "$(pyenv init -)"
alias pipallupgrade="pip freeze --local | grep -v '^\-e' | cut -d = -f 1  | xargs pip install -U"

# -----------------------------
# Golang
# -----------------------------
if which go > /dev/null 2>&1  ; then
  export CGO_ENABLED=1
  export GOPATH=$HOME/dev/go
  export PATH=$PATH:$(go env GOROOT)/bin:$GOPATH/bin
fi

# fd - cd to selected directory
# sudo apt-get install fzf
function fd() {
  local dir
  # dir=$(find ${1:-.} -path '*/\.*' -prune -o -type d -print 2> /dev/null | fzf +m) &&
  dir=$(find ~/Desktop -path '*/\.*' -prune -o -type d -print 2> /dev/null | fzf +m) &&
  cd "$dir"
}

# Gitリポジトリの一覧を取得し、fzfで選択して移動する関数
# function fg() {
#   local repo
#   repo=$(git rev-parse --show-toplevel 2>/dev/null) # 現在のディレクトリがGitリポジトリか確認

#   if [[ -n "$repo" ]]; then
#     echo "すでにGitリポジトリにいるので移動しませんか？"
#   else
#     # Gitリポジトリの一覧を取得してfzfで選択
#     repo=$(find ~/Desktop -type d -name ".git" -prune 2>/dev/null | sed 's/\.git$//')
#     local selected_repo

#     if [[ -n "$repo" ]]; then
#       selected_repo=$(echo "$repo" | fzf --prompt="Select a Git repository: ")
#       if [[ -n "$selected_repo" ]]; then
#         cd "$selected_repo"
#       fi
#     else
#       echo "No Git repositories found."
#     fi
#   fi
# }

# Ctrl+Rを押して履歴検索を開始
bindkey '^R' fzf_history 
function select-history() {
  BUFFER=$(history -n -r 1 | fzf --no-sort +m --query "$LBUFFER" --prompt="History > ")
  CURSOR=$#BUFFER
}
zle -N select-history
bindkey '^r' select-history



# makeを自動で実行するコマンド
# sudo apt install inotifywait-tools がいる
# buildディレクトリに行って、mを打つ
function m(){
  inotifywait -e create,delete,modify,move -mr ../  --exclude ../build |while read;do while read -t 0.3;
do :;done;
  make -j4;
done;
}

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

if [[ -f $HOME/.cargo/env ]]; then
  source $HOME/.cargo/env
fi

# コマンドを自動で修正するのをDisableにする
unsetopt correct;
unsetopt correct_all;
DUSABLE_CORRECTION="true";

export PATH=${PATH}:~/.myenv/bin/:~/.local/bin
export PATH=${PATH}:~/.myenv/gcc-linaro-arm-linux-gnueabihf-4.7-2013.04-20130415_linux/bin
export PATH="$PATH:`yarn global bin`"

export CC=/usr/bin/clang-17
export CXX=/usr/bin/clang++-17

# export ANDROID_HOME=/usr/lib/android-sdk
# export PATH=$HOME/.nodebrew/current/bin:$ANDROID_HOME/tools/bin:$ANDROID_HOME/platform-tools:$PATH
# export ANDROID_SDK_ROOT=$ANDROID_HOME
# tmux source ~/.tmux.conf

export LD_LIBRARY_PATH="$LD_LIBRARY_PATH:/usr/lib/x86_64-linux-gnu/:/usr/local/lib/"


# minikubeがある場合は kubectl = minkube kubectl にする
if which minikube > /dev/null 2>&1  ; then
  alias kubectl="minikube kubectl --"
fi

