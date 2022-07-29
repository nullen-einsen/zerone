#!/usr/bin/env bash

#########################################################################
# Script to setup the RBP with LAMP Stack, Tor Service and LCD Drivers
# Source Repo: https://github.com/nullen-einsen/zerone
# Author: 3k1n
# setup fresh SD card with image above - login per SSH and run this script:
##########################################################################

sudo -su root

echo "**********************************************"
echo "*     NULL3N & E1NSEN SD CARD IMAGE SETUP    *"
echo "**********************************************"
echo

#DEBIAN_FRONTEND=noninteractive

echo -e "\n*** UPDATE Debian***"
apt update -y
apt upgrade -f -y

echo -e "\n*** SOFTWARE UPDATE ***"
apt install \
    git-all \
    nginx \
    ufw \
    qrencode \
    fbi \
    -y

## WEBSERVER
echo -e "\n*** Configuring Firewall ***"
# Configure Firewall
# https://www.codingforentrepreneurs.com/blog/hello-linux-nginx-and-ufw-firewall/
ufw allow ssh
ufw allow 'Nginx Full'
#ufw enable


## TOR
# Install TOR
# https://support.torproject.org/apt/
apt install apt-transport-https -y
touch /etc/apt/sources.list.d/tor.list
echo "   deb     [signed-by=/usr/share/keyrings/tor-archive-keyring.gpg] https://deb.torproject.org/torproject.org bullseye main" >> /etc/apt/sources.list.d/tor.list
echo "   deb-src [signed-by=/usr/share/keyrings/tor-archive-keyring.gpg] https://deb.torproject.org/torproject.org bullseye main" >> /etc/apt/sources.list.d/tor.list
wget -qO- https://deb.torproject.org/torproject.org/A3C4F0F979CAA22CDBA8F512EE8CBC9E886DDD89.asc | gpg --dearmor | tee /usr/share/keyrings/tor-archive-keyring.gpg >/dev/null
apt update -y
apt install tor deb.torproject.org-keyring -y
sed '/HiddenServiceDir/s/^#//g' -i /etc/tor/torrc
sed '/HiddenServicePort/s/^#//g' -i /etc/tor/torrc
systemctl restart tor


## QR CODE
# Create QR code from onion url and save as png
cat /var/lib/tor/hidden_service/hostname | qrencode --foreground="ffffff" --background="000000" -o /home/pi/qr.png

## LCD SCREEN
# prepare auto-start of qrinfo.sh script on pi user login
bash -c 'echo "# automatic start the QR info loop" >> /home/pi/.bashrc'
bash -c 'echo "# load QR code into frame buffer" >> /home/pi/.bashrc'
bash -c 'echo "sudo fbi -a -T 1 -d /dev/fb0 --noverbose /home/pi/qr.png 2> /dev/null" >> /home/pi/.bashrc'
echo "autostart LCD added"

echo -e "\n*** ADDING MAIN USER admin ***"
# based on https://raspibolt.org/system-configuration.html#add-users
# using the default password 'admin'
adduser --disabled-password --gecos "" admin
echo "admin:admin" | chpasswd
adduser admin sudo
chsh admin -s /bin/bash
# configure sudo for usage without password entry
echo '%sudo ALL=(ALL) NOPASSWD:ALL' | EDITOR='tee -a' visudo
# check if group "admin" was created
if [ $(sudo cat /etc/group | grep -c "^admin") -lt 1 ]; then
  echo -e "\nMissing group admin - creating it ..."
  /usr/sbin/groupadd --force --gid 1002 admin
  usermod -a -G admin admin
else
  echo -e "\nOK group admin exists"
fi

# Install LCD Drivers (triggers reboot after install)
echo "# INSTALL 64bit LCD DRIVER"
# https://github.com/tux1c/wavesharelcd-64bit-rpi
cd /home/admin
git clone https://github.com/tux1c/wavesharelcd-64bit-rpi.git
cd wavesharelcd-64bit-rpi
chmod +x install.sh
bash install.sh

echo "# BUILD DONE - see above"
