# dotfilesをホームディレクトリにリンクする

# current dir
DOTFILES_DIR=$(cd $(dirname $0); pwd)

for file in .zshrc .gitignore .tmux.conf .clang-format .bashrc
do
  rm -rf $HOME/$file
  ln -s $DOTFILES_DIR/$file $HOME/$file
done

rm -rf ~/.config/nvim/init.vim
ln -s $DOTFILES_DIR/init.vim ~/.config/nvim/init.vim

