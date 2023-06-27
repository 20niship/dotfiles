echo "------------------------------   Install start   ------------------------------"
sudo apt update
sudo apt upgrade

sudo apt install -y git ripgrep make cmake zsh tmux curl wget 

# C++ packages
sudo apt install -y libboost-all-dev libgl-dev libxcursor-dev libxi-dev libxinerama-dev libxrandr-dev mesa-vulkan-drivers libopencv-dev libx11-dev xorg-dev libglu1-mesa libgl1-mesa-glx libglu1-mesa-dev libgl1-mesa-dev libglfw3 libglfw3-dev libglew-dev libglm-dev libfreetype6-dev libeigen3-dev libassimp-dev libpcl-dev libopencv-dev python3-opencv lua5.4-dev
sudo apt-get install -y libx11-dev xorg-dev libglu1-mesa libglu1-mesa-dev libgl1-mesa-glx libgl1-mesa-dev libglfw3 libglfw3-dev libglew-dev libglu1-mesa-dev freeglut3-dev mesa-common-dev

# echo "------------------------------   Install Python   ------------------------------"
# # Python
# sudo apt install -y software-properties-common
# sudo add-apt-repository ppa:deadsnakes/ppa
# sudo apt install -y python3.9
# python3 --version


echo "------------------------------   Install NeoVim------------------------------"
sudo add-apt-repository ppa:neovim-ppa/unstable
sudo apt update
sudo apt install neovim


echo "Install dein"
curl https://raw.githubusercontent.com/Shougo/dein.vim/master/bin/installer.sh > dein_installer.sh
sh ./dein_installer.sh ~/.cache/dein

echo "------------------------------   Install Node js ------------------------------"
# 最新バージョンのNode.jsをインストールする
# 確実にインストールするには、公式サイトからBinaryをダウンロードし、指定の場所に解凍→PATHに追加のほうが良い
curl -sL https://deb.nodesource.com/setup_20.x | sudo -E bash -
sudo apt install -y nodejs


echo "------------------------------   Install Docker  ------------------------------"
# Docker, docker-compose
# 公式サイトの通りにするとエラーがでるので　、下記サイトを参考に行う
# https://www.digitalocean.com/community/tutorials/how-to-install-and-use-docker-on-ubuntu-20-04-ja
sudo apt install apt-transport-https ca-certificates curl software-properties-common
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu focal stable"
sudo apt update
sudo apt install -y docker-ce
sudo apt install -y docker-ce-cli
sudo apt install -y containerd.io
 
 # Docker compose
 sudo curl -L "https://github.com/docker/compose/releases/download/1.29.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
 sudo chmod +x /usr/local/bin/docker-compose
 sudo ln -s /usr/local/bin/docker-compose /usr/bin/docker-compose
 docker-compose --version
 

# Dockerをsudoなしで実行する　https://qiita.com/DQNEO/items/da5df074c48b012152ee
sudo groupadd docker
sudo gpasswd -a $USER docker
sudo systemctl restart docker
