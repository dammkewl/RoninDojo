#!/bin/bash
# shellcheck disable=SC2154 source=/dev/null

. "$HOME"/RoninDojo/Scripts/defaults.sh
. "$HOME"/RoninDojo/Scripts/functions.sh

if [ -d ~/dojo ]; then
  echo -e "${RED}"
  echo "***"
  echo "Dojo directory found, please uninstall Dojo first!"
  echo "***"
  echo -e "${NC}"
  _sleep 5
  bash ~/RoninDojo/Scripts/Menu/menu-dojo2.sh
else
  echo -e "${RED}"
  echo "***"
  echo "Setting up system and installing Dependencies in 15s..."
  echo "***"
  echo -e "${NC}"
  _sleep 5
fi
# checks for ~/dojo directory, if found kicks back to menu

echo -e "${RED}"
echo "***"
echo "Use Ctrl+C to exit now if needed!"
echo "***"
echo -e "${NC}"
_sleep 10

~/RoninDojo/Scripts/.logo
# display ronindojo logo

test -f /etc/motd && sudo rm /etc/motd
# remove ssh banner for the script logo

if _disable_bluetooth; then
  echo -e "${RED}"
  echo "***"
  echo "Disabling Bluetooth..."
  echo "***"
  echo -e "${NC}"
fi
# disable bluetooth, see functions.sh

if _disable_ipv6; then
  echo -e "${RED}"
  echo "***"
  echo "Disabling Ipv6..."
  echo "***"
  echo -e "${NC}"
fi
# disable ipv6, see functions.sh

# Install system dependencies
for pkg in "${!package_dependencies[@]}"; do
  if hash "${pkg}" 2>/dev/null; then
    cat <<EOF
${RED}
***
${package_dependencies[$pkg]} already installed...
***
${NC}
EOF
    _sleep
  else
    cat <<EOF
${RED}
***
Installing ${package_dependencies[$pkg]}...
***
${NC}
EOF
    _sleep
    sudo pacman -S --noconfirm "${package_dependencies[$pkg]}"
  fi
done
# install system dependencies, see defaults.sh
# websearch "bash associative array" for info

if ! grep /mnt/usb/tor /etc/tor/torrc 1>/dev/null; then
  sudo sed -i -e 's:^DataDirectory .*$:DataDirectory /mnt/usb/tor:' \
    -e 's/^ControlPort .*$/ControlPort 9051/' \
    -e 's/^#CookieAuthentication/CookieAuthentication/' \
    -e '/CookieAuthentication/a CookieAuthFileGroupReadable 1' /etc/tor/torrc
fi
# check if /etc/tor/torrc is configured

if sudo ufw status | grep 22 > /dev/null ; then
  echo -e "${RED}"
  echo "***"
  echo "SSH firewall rule already setup..."
  echo "***"
  echo -e "${NC}"
  _sleep
else
  echo -e "${RED}"
  echo "***"
  echo "Setting up UFW..."
  echo "***"
  echo -e "${NC}"
  _sleep 2
  sudo ufw default deny incoming
  sudo ufw default allow outgoing
  # setting up uncomplicated firewall

  echo -e "${RED}"
  echo "***"
  echo "Enabling UFW..."
  echo "***"
  echo -e "${NC}"
  _sleep 2
  sudo ufw --force enable
  sudo systemctl enable ufw
  # enabling ufw so /etc/ufw/user.rules file configures properly, then edit using awk and sed below

  ip addr | sed -rn '/state UP/{n;n;s:^ *[^ ]* *([^ ]*).*:\1:;s:[^.]*$:0/24:p}' > ~/ip_tmp.txt
  # creates ip_tmp.txt with IP address listed in ip addr, and makes ending .0/24

  while read -r ip ; do echo "### tuple ### allow any 22 0.0.0.0/0 any $ip" > ~/rule_tmp.txt; done <~/ip_tmp.txt
  # pipes output from ip_tmp.txt into read, then uses echo to make next text file with needed changes plus the ip address
  # for line 19 in /etc/ufw/user.rules

  while read -r ip ; do echo "-A ufw-user-input -p tcp --dport 22 -s $ip -j ACCEPT" >> ~/rule_tmp.txt; done <~/ip_tmp.txt
  # pipes output from ip_tmp.txt into read, then uses echo to make next text file with needed changes plus the ip address
  # for line 20 /etc/ufw/user.rules

  while read -r ip ; do echo "-A ufw-user-input -p udp --dport 22 -s $ip -j ACCEPT" >> ~/rule_tmp.txt; done <~/ip_tmp.txt
  # pipes output from ip_tmp.txt into read, then uses echo to make next text file with needed changes plus the ip address
  # for line 21 /etc/ufw/user.rules

  awk 'NR==1{a=$0}NR==FNR{next}FNR==19{print a}1' ~/rule_tmp.txt /etc/ufw/user.rules > ~/user.rules_tmp.txt && sudo mv ~/user.rules_tmp.txt /etc/ufw/user.rules
  # copying from line 1 in rule_tmp.txt to line 19 in /etc/ufw/user.rules
  # using awk to get /lib/ufw/user.rules output, including newly added values, then makes a tmp file
  # after temp file is made it is mv to /lib/ufw/user.rules
  # awk does not have -i to write changes like sed does, that's why I took this approach

  awk 'NR==2{a=$0}NR==FNR{next}FNR==20{print a}1' ~/rule_tmp.txt /etc/ufw/user.rules > ~/user.rules_tmp.txt && sudo mv ~/user.rules_tmp.txt /etc/ufw/user.rules
  # copying from line 2 in rule_tmp.txt to line 20 in /etc/ufw/user.rules

  awk 'NR==3{a=$0}NR==FNR{next}FNR==21{print a}1' ~/rule_tmp.txt /etc/ufw/user.rules > ~/user.rules_tmp.txt && sudo mv ~/user.rules_tmp.txt /etc/ufw/user.rules
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
  _sleep 2
  sudo ufw reload

  echo -e "${RED}"
  echo "***"
  echo "Checking UFW status..."
  echo "***"
  echo -e "${NC}"
  _sleep 2
  sudo ufw status
  _sleep 4

  echo -e "${RED}"
  echo "***"
  echo "Now that UFW is enabled, any computer connected to the same local network as your RoninDojo will have SSH access."
  echo "***"
  echo -e "${NC}"
  _sleep 5

  echo -e "${RED}"
  echo "***"
  echo "Leaving this setting default is NOT RECOMMENDED for users who are connecting to something like University, Public Internet, Etc."
  echo "***"
  echo -e "${NC}"
  _sleep 5

  echo -e "${RED}"
  echo "***"
  echo "Firewall rules can be adjusted using the RoninDojo Firewall Menu."
  echo "***"
  echo -e "${NC}"
  _sleep 5
fi

echo -e "${RED}"
echo "***"
echo "All Dojo dependencies installed..."
echo "***"
echo -e "${NC}"
_sleep 3

echo -e "${RED}"
echo "***"
echo "***"
echo -e "${NC}"
_docker_setup

echo -e "${RED}"
echo "***"
echo "Dojo is ready to be installed!"
echo "***"
echo -e "${NC}"
_sleep 3
# will continue to dojo install if it was selected on the install menu
