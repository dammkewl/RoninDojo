#!/bin/bash

RED='\033[0;31m'
# used for color with ${RED}
YELLOW='\033[1;33m'
# used for color with ${YELLOW}
NC='\033[0m'
# No Color

USER=$(sudo cat /etc/passwd | grep 1000 | awk -F: '{ print $1}' | cut -c 1-)

echo -e "${RED}"
echo "***"
echo "Upgrading Dojo in 30s..."
echo "***"
echo -e "${NC}"
sleep 3s

echo -e "${RED}"
echo "***"
echo "Use Ctrl+C to exit if needed!"
echo "***"
echo -e "${NC}"
sleep 1s

cd ~/dojo/docker/my-dojo
sudo ./dojo.sh stop
sudo chown -R $USER:$USER ~/dojo/*
mkdir ~/.dojo > /dev/null 2>&1
cd ~/.dojo
sudo rm -rf samourai-dojo > /dev/null 2>&1
git clone https://github.com/Samourai-Wallet/samourai-dojo.git
cd samourai-dojo
git checkout v1.5.0
cd ..
cp -rv samourai-dojo/* ~/dojo
# stop dojo and prepare for upgrade

echo -e "${RED}"
echo "***"
echo "Installing your Dojo-backed Bitcoin Explorer..."
echo "***"
echo -e "${NC}"
sleep 2s

echo -e "${RED}"
echo "***"
echo "A randomly generated 16 character password will be created if you haven't already made one."
echo "***"
echo -e "${NC}"
sleep 3s

if [ ! -f ~/dojo/docker/my-dojo/conf/docker-explorer.conf ] ; then
    EXPLORER_KEY=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 16 | head -n 1)
else
    echo -e "${RED}"
    echo "***"
    echo "Explorer is already installed!"
    echo "***"
    echo -e "${NC}"
fi

sed -i '16i EXPLORER_KEY='$EXPLORER_KEY'' ~/dojo/docker/my-dojo/conf/docker-explorer.conf.tpl
sed -i '17d' ~/dojo/docker/my-dojo/conf/docker-explorer.conf.tpl

if [ ! -f ~/dojo/docker/my-dojo/conf/docker-indexer.conf ] ; then
    read -p "Do you want to install an Indexer? [y/n]" yn
    case $yn in
        [Y/y]* ) sudo sed -i '9d' ~/dojo/docker/my-dojo/conf/docker-indexer.conf.tpl;
                 sudo sed -i '9i INDEXER_INSTALL=on' ~/dojo/docker/my-dojo/conf/docker-indexer.conf.tpl;
                 sudo sed -i '25d' ~/dojo/docker/my-dojo/conf/docker-node.conf.tpl;
                 sudo sed -i '25i NODE_ACTIVE_INDEXER=local_indexer' ~/dojo/docker/my-dojo/conf/docker-node.conf.tpl;;
        [N/n]* ) echo -e "${RED}"
                 echo "***"
                 echo "Indexer will not be installed!"
                 echo "***"
                 echo -e "${NC}";;
        * ) echo "Please answer Yes or No.";;
    esac
elif cat ~/dojo/docker/my-dojo/conf/docker-indexer.conf | grep "INDEXER_INSTALL=off" > /dev/null ; then
        read -p "Do you want to install an Indexer? [y/n]" yn
        case $yn in
            [Y/y]* ) sudo sed -i '9d' ~/dojo/docker/my-dojo/conf/docker-indexer.conf;
                     sudo sed -i '9i INDEXER_INSTALL=on' ~/dojo/docker/my-dojo/conf/docker-indexer.conf;
                     sudo sed -i '25d' ~/dojo/docker/my-dojo/conf/docker-node.conf;
                     sudo sed -i '25i NODE_ACTIVE_INDEXER=local_indexer' ~/dojo/docker/my-dojo/conf/docker-node.conf;;
            [N/n]* ) echo -e "${RED}"
                     echo "***"
                     echo "Indexer will not be installed!"
                     echo "***"
                     echo -e "${NC}";;
            * ) echo "Please answer Yes or No.";;
        esac
    else
        echo -e "${RED}"
        echo "***"
        echo "Indexer is already installed! If you were running Electrs, press y at next prompt..."
        echo "***"
        echo -e "${NC}"
fi

# Run upgrade
cd ~/dojo/docker/my-dojo
sudo ./dojo.sh upgrade
# run upgrade

bash ~/RoninDojo/Scripts/Menu/menu-dojo.sh
# return to menu
