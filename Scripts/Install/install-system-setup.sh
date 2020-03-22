#!/bin/bash

RED='\033[0;31m'
# used for color with ${RED}
NC='\033[0m'
# No Color

if ls ~ | grep dojo > /dev/null ; then
  echo -e "${RED}"
  echo "***"
  echo "Dojo directory found, please uninstall Dojo first!"
  echo "***"
  echo -e "${NC}"
  sleep 5s
  bash ~/RoninDojo/Scripts/Menu/menu-dojo2.sh
else
  echo -e "${RED}"
  echo "***"
  echo "Setting up system and installing Dependencies in 15s..."
  echo "***"
  echo -e "${NC}"
  sleep 5s
fi
# checks for ~/dojo directory, if found kicks back to menu

echo -e "${RED}"
echo "***"
echo "If you have already setup your system, use Ctrl+C to exit now!"
echo "***"
echo -e "${NC}"
sleep 5s

echo -e "${NC}"
echo " _____________________________________________________|_._._._._._._._._, "
echo " \____________________________________________________|_|_|_|_|_|_|_|_|_| "
echo "                                                      !                   "
echo -e "${RED}"
echo " I dreamt of        ______            _          _   _ _                  "
echo "   worldly success  | ___ \          (_)        | | | (_)                 "
echo "               once.| |_/ /___  _ __  _ _ __    | | | |_|                 "
echo "                    |    // _ \| '_ \| | '_ \   | | | | |                 "
echo "                    | |\ \ (_) | | | | | | | |  | |_| | |                 "
echo "                    \_| \_\___/|_| |_|_|_| |_|by\____/|_|                 "
echo "                                              @GuerraMoneta               "
echo -e "                                            & @BTCxZelko          ${NC}"
echo " ,_._._._._._._._._|_____________________________________________________ "
echo " |_|_|_|_|_|_|_|_|_|____________________________________________________/ "
echo "                   !                                                      "
echo -e "${NC}"
sleep 5s

# system setup starts
sudo rm -rf /etc/motd
# remove ssh banner for the script logo

if ls /boot | grep cmdline.txt > /dev/null ; then
  echo -e "${RED}"
  echo "***"
  echo "Disabling Ipv6 for Raspberry Pi4..."
  echo "***"
  echo -e "${NC}"
  cat /boot/cmdline.txt > ~/cmdline.txt
  sudo sed -i '/^root=/s/$/ ipv6.disable=1/' ~/cmdline.txt
  sudo chown root:root ~/cmdline.txt
  sudo chmod 755 ~/cmdline.txt
  sudo mv ~/cmdline.txt /boot/cmdline.txt
  sleep 2s
else
  echo -e "${RED}"
  echo "***"
  echo "Disabling Ipv6 for Odroid N2..."
  echo "***"
  echo -e "${NC}"
  cat /boot/boot.ini > ~/boot.ini
  sudo sed -i '/^setenv bootargs/s/$/ ipv6.disable=1/' ~/boot.ini
  sudo chown root:root ~/boot.ini
  sudo chmod 755 ~/boot.ini
  sudo mv ~/boot.ini /boot/boot.ini
  sleep 2s
fi
# disable ipv6
# chmod and chown to avoid errors when moving from ~ to ~/boot
# /boot/cmdline.txt file will only be there if it's a Raspberry Pi
# /boot/boot.ini is for Odroid N2

check1=ronin
if ls /usr/local/bin | grep $check1 > /dev/null ; then
  echo ""
else
  sudo cp ~/RoninDojo/ronin /usr/local/bin/ronin
  echo "" >> ~/.bashrc
  echo "~/RoninDojo/Scripts/.logo" >> ~/.bashrc
  echo "" >> ~/.bashrc
  echo "~/RoninDojo/ronin" >> ~/.bashrc
fi
# place main ronin menu  script under /usr/local/bin folder, because most likely that will be path already added to your $PATH variable
# place logo and ronin main menu script ~/.bashrc to run at each login

sudo chmod +x ~/RoninDojo/Scripts/Install/*
sudo chmod +x ~/RoninDojo/Scripts/Menu/*

check2='jdk11-openjdk /usr/share/licenses/java11-openjdk/'
if pacman -Ql | grep "$check2" > /dev/null ; then
  echo -e "${RED}"
  echo "***"
  echo "Java already installed..."
  echo "***"
  echo -e "${NC}"
  sleep 1s
else
  echo -e "${RED}"
  echo "***"
  echo "Installing Java..."
  echo "***"
  echo -e "${NC}"
  sleep 1s
  sudo pacman -S --noconfirm jdk11-openjdk
fi
# installs java jdk11-openjdk
# in had to use '' and "" for the check to work correctly
# single quotes won't interpolate anything, but double quotes will

check3=/usr/bin/tor
if pacman -Ql | grep $check3  > /dev/null ; then
    echo -e "${RED}"
    echo "***"
    echo "Tor already installed..."
    echo "***"
    echo -e "${NC}"
    sleep 1s
else
    echo -e "${RED}"
    echo "***"
    echo "Installing Tor..."
    echo "***"
    echo -e "${NC}"
    sudo pacman -S --noconfirm tor
    sleep 1s
    sudo sed -i '52d' /etc/tor/torrc
    sudo sed -i '52i DataDirectory /mnt/usb/tor' /etc/tor/torrc
    sudo sed -i '56d' /etc/tor/torrc
    sudo sed -i '56i ControlPort 9051' /etc/tor/torrc
    sudo sed -i '60d' /etc/tor/torrc
    sudo sed -i '60i CookieAuthentication 1' /etc/tor/torrc
    sudo sed -i '61i CookieAuthFileGroupReadable 1' /etc/tor/torrc
fi
# check if tor is installed, if not install and modify torrc

check4='python /usr/bin/python3'
if pacman -Ql | grep "$check4" > /dev/null ; then
  echo -e "${RED}"
  echo "***"
  echo "Python3 already installed..."
  echo "***"
  echo -e "${NC}"
  sleep 1s
else
  echo -e "${RED}"
  echo "***"
  echo "Installing Python3..."
  echo "***"
  echo -e "${NC}"
  sleep 1s
  sudo pacman -S --noconfirm python3
fi
# checks for python, if python not found then it is installed
# in had to use '' and "" for the check to work correctly
# single quotes won't interpolate anything, but double quotes will

check5=fail2ban
if pacman -Qs $check5 > /dev/null ; then
  echo -e "${RED}"
  echo "***"
  echo "Fail2ban already installed..."
  echo "***"
  echo -e "${NC}"
  sleep 1s
else
  echo -e "${RED}"
  echo "***"
  echo "Installing Fail2ban..."
  echo "***"
  echo -e "${NC}"
  sleep 1s
  sudo pacman -S --noconfirm fail2ban
fi
# check for / install fail2ban

check6=htop
if pacman -Qs $check6 > /dev/null ; then
  echo -e "${RED}"
  echo "***"
  echo "Htop already installed..."
  echo "***"
  echo -e "${NC}"
  sleep 1s
else
  echo -e "${RED}"
  echo "***"
  echo "Installing Htop..."
  echo "***"
  echo -e "${NC}"
  sleep 1s
  sudo pacman -S --noconfirm htop
fi
# check for / install htop

check7=vim
if pacman -Qs $check7 > /dev/null ; then
  echo -e "${RED}"
  echo "***"
  echo "Vim already installed..."
  echo "***"
  echo -e "${NC}"
  sleep 1s
else
  echo -e "${RED}"
  echo "***"
  echo "Installing Vim..."
  echo "***"
  echo -e "${NC}"
  sleep 1s
  sudo pacman -S --noconfirm vim
fi
# check for / install vim

check8=unzip
if pacman -Qs $check8 > /dev/null ; then
  echo -e "${RED}"
  echo "***"
  echo "Unzip already installed..."
  echo "***"
  echo -e "${NC}"
  sleep 1s
else
  echo -e "${RED}"
  echo "***"
  echo "Installing Unzip..."
  echo "***"
  echo -e "${NC}"
  sleep 1s
  sudo pacman -S --noconfirm unzip
fi
# check for / install unzip

check9=net-tools
if pacman -Qs $check9 > /dev/null ; then
  echo -e "${RED}"
  echo "***"
  echo "Net-tools already installed..."
  echo "***"
  echo -e "${NC}"
  sleep 1s
else
  echo -e "${RED}"
  echo "***"
  echo "Installing Net-tools..."
  echo "***"
  echo -e "${NC}"
  sleep 1s
  sudo pacman -S --noconfirm net-tools
fi
# check for / install net tools

check10=/usr/bin/which
if sudo pacman -Ql | grep $check10 > /dev/null ; then
  echo -e "${RED}"
  echo "***"
  echo "Which already installed..."
  echo "***"
  echo -e "${NC}"
  sleep 1s
else
  echo -e "${RED}"
  echo "***"
  echo "Installing Which..."
  echo "***"
  echo -e "${NC}"
  sleep 1s
  sudo pacman -S --noconfirm which
fi
# check for / install which

check11=wget
if pacman -Qs $check11 > /dev/null ; then
  echo -e "${RED}"
  echo "***"
  echo "Wget already installed..."
  echo "***"
  echo -e "${NC}"
  sleep 1s
else
  echo -e "${RED}"
  echo "***"
  echo "Installing Wget..."
  echo "***"
  echo -e "${NC}"
  sleep 1s
  sudo pacman -S --noconfirm wget
fi
# check for / install wget

check12=docker
if pacman -Qs $check12 > /dev/null ; then
  echo -e "${RED}"
  echo "***"
  echo "Docker already installed..."
  echo "***"
  echo -e "${NC}"
  sleep 1s
else
  echo -e "${RED}"
  echo "***"
  echo "Installing Docker..."
  echo "***"
  echo -e "${NC}"
  sleep 1s
  sudo pacman -S --noconfirm docker
fi
# check for / install docker

check13=docker-compose
if pacman -Qs $check13 > /dev/null ; then
  echo -e "${RED}"
  echo "***"
  echo "Docker-compose already installed..."
  echo "***"
  echo -e "${NC}"
  sleep 1s
else
  echo -e "${RED}"
  echo "***"
  echo "Installing Docker-compose..."
  echo "***"
  echo -e "${NC}"
  sleep 1s
  sudo pacman -S --noconfirm docker-compose
fi
# check for / install docker

sudo systemctl enable docker
# enables docker to run at startup
# system setup ends

check14=ufw
if pacman -Qs $check14 > /dev/null ; then
  echo -e "${RED}"
  echo "***"
  echo "Ufw already installed..."
  echo "***"
  echo -e "${NC}"
  sleep 1s
else
  echo -e "${RED}"
  echo "***"
  echo "Installing Ufw..."
  echo "***"
  echo -e "${NC}"
  sleep 1s
  sudo pacman -S --noconfirm ufw
fi
# check for / install ufw

if sudo ufw status | grep 22 > /dev/null ; then
  echo -e "${RED}"
  echo "***"
  echo "Ssh firewall rule already setup..."
  echo "***"
  echo -e "${NC}"
  sleep 1s
else
  # ufw setup starts
  echo -e "${RED}"
  echo "***"
  echo "Setting up UFW..."
  echo "***"
  echo -e "${NC}"
  sleep 2s
  sudo ufw default deny incoming
  sudo ufw default allow outgoing

  echo -e "${RED}"
  echo "***"
  echo "Enabling UFW..."
  echo "***"
  echo -e "${NC}"
  sleep 2s
  sudo ufw --force enable
  sudo systemctl enable ufw
  # enabling ufw so /etc/ufw/user.rules file configures properly, then edit using awk and sed below

  ip addr | sed -rn '/state UP/{n;n;s:^ *[^ ]* *([^ ]*).*:\1:;s:[^.]*$:0/24:p}' > ~/ip_tmp.txt
  # creates ip_tmp.txt with IP address listed in ip addr, and makes ending .0/24

  cat ~/ip_tmp.txt | while read ip ; do echo "### tuple ### allow any 22 0.0.0.0/0 any ""$ip" > ~/rule_tmp.txt; done
  # pipes output from ip_tmp.txt into read, then uses echo to make next text file with needed changes plus the ip address
  # for line 19 in /etc/ufw/user.rules

  cat ~/ip_tmp.txt | while read ip ; do echo "-A ufw-user-input -p tcp --dport 22 -s "$ip" -j ACCEPT" >> ~/rule_tmp.txt; done
  # pipes output from ip_tmp.txt into read, then uses echo to make next text file with needed changes plus the ip address
  # for line 20 /etc/ufw/user.rules

  cat ~/ip_tmp.txt | while read ip ; do echo "-A ufw-user-input -p udp --dport 22 -s "$ip" -j ACCEPT" >> ~/rule_tmp.txt; done
  # pipes output from ip_tmp.txt into read, then uses echo to make next text file with needed changes plus the ip address
  # for line 21 /etc/ufw/user.rules

  sudo awk 'NR==1{a=$0}NR==FNR{next}FNR==19{print a}1' ~/rule_tmp.txt /etc/ufw/user.rules > ~/user.rules_tmp.txt && sudo mv ~/user.rules_tmp.txt /etc/ufw/user.rules
  # copying from line 1 in rule_tmp.txt to line 19 in /etc/ufw/user.rules
  # using awk to get /lib/ufw/user.rules output, including newly added values, then makes a tmp file
  # after temp file is made it is mv to /lib/ufw/user.rules
  # awk does not have -i to write changes like sed does, that's why I took this approach

  sudo awk 'NR==2{a=$0}NR==FNR{next}FNR==20{print a}1' ~/rule_tmp.txt /etc/ufw/user.rules > ~/user.rules_tmp.txt && sudo mv ~/user.rules_tmp.txt /etc/ufw/user.rules
  # copying from line 2 in rule_tmp.txt to line 20 in /etc/ufw/user.rules

  sudo awk 'NR==3{a=$0}NR==FNR{next}FNR==21{print a}1' ~/rule_tmp.txt /etc/ufw/user.rules > ~/user.rules_tmp.txt && sudo mv ~/user.rules_tmp.txt /etc/ufw/user.rules
  # copying from line 3 in rule_tmp.txt to line 21 in /etc/ufw/user.rules

  sudo sed -i "18G" /etc/ufw/user.rules
  # adds a space to keep things formatted nicely

  sudo chown root:root /etc/ufw/user.rules
  # this command changes ownership back to root:root
  # when /etc/ufw/user.rules is edited using awk or sed, the owner gets changed from Root to whatever User that edited that file
  # that causes a warning to be displayed as /etc/ufw/user.rules does need to be owned by root:root

  sudo rm ~/ip_tmp.txt ~/rule_tmp.txt
  # removes txt files that are no longer needed

  echo -e "${RED}"
  echo "***"
  echo "Reloading UFW..."
  echo "***"
  echo -e "${NC}"
  sleep 2s
  sudo ufw reload

  echo -e "${RED}"
  echo "***"
  echo "Checking UFW status..."
  echo "***"
  echo -e "${NC}"
  sleep 2s
  sudo ufw status
  sleep 4s

  echo -e "${RED}"
  echo "***"
  echo "Now that UFW is enabled, any computer connected to the same local network as your RoninDojo will have SSH access."
  echo "***"
  echo -e "${NC}"
  sleep 5s

  echo -e "${RED}"
  echo "***"
  echo "Leaving this setting default is NOT RECOMMENDED for users who are conncting to something like University, Public Internet, Etc."
  echo "***"
  echo -e "${NC}"
  sleep 5s

  echo -e "${RED}"
  echo "***"
  echo "Firewall rules can be adjusted using the RoninDojo Firewall Menu."
  echo "***"
  echo -e "${NC}"
  sleep 5s
  # ufw setup ends
fi

echo -e "${RED}"
echo "***"
echo "All Dojo dependencies installed..."
echo "***"
echo -e "${NC}"
sleep 3s

echo -e "${RED}"
echo "***"
echo "Checking docker version..."
echo "***"
echo -e "${NC}"
docker -v
sleep 3s

echo -e "${RED}"
echo "***"
echo "Restarting docker..."
echo "***"
echo -e "${NC}"
sudo systemctl stop docker
sleep 15s
sudo systemctl daemon-reload
sleep 5s
sudo systemctl start docker
sleep 10s
sudo systemctl enable docker
# sleep here to avoid error systemd[1]: Failed to start Docker Application Container Engine
# see systemctl status docker.service and journalctl -xe for details on error

# docker setup ends

echo -e "${RED}"
echo "***"
echo "Dojo is ready to be installed!"
echo "***"
echo -e "${NC}"
sleep 3s
# will continue to dojo install if it was selected on the install menu
