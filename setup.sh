#!/usr/bin/env bash

#########################################################################
# Script to setup the RBP with LAMP Stack, Tor Service and LCD Drivers
# Source Repo: https://github.com/nullen-einsen/zerone
# Author: 3k1n
# setup fresh SD card with image above - login per SSH and run this script:
##########################################################################

export DEBIAN_FRONTEND=noninteractive

echo "**********************************************"
echo "*     NULL3N & E1NSEN SD CARD IMAGE SETUP    *"
echo "**********************************************"
echo

#DEBIAN_FRONTEND=noninteractive

echo -e "\n*** UPDATE Debian***"
sudo apt update -y
sudo apt upgrade -f -y

echo -e "\n*** SOFTWARE UPDATE ***"
sudo apt install \
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
sudo apt install apt-transport-https -y
sudo touch /etc/apt/sources.list.d/tor.list
sudo echo "   deb     [signed-by=/usr/share/keyrings/tor-archive-keyring.gpg] https://deb.torproject.org/torproject.org bullseye main" | sudo tee -a /etc/apt/sources.list.d/tor.list
sudo echo "   deb-src [signed-by=/usr/share/keyrings/tor-archive-keyring.gpg] https://deb.torproject.org/torproject.org bullseye main" | sudo tee -a /etc/apt/sources.list.d/tor.list
wget -qO- https://deb.torproject.org/torproject.org/A3C4F0F979CAA22CDBA8F512EE8CBC9E886DDD89.asc | gpg --dearmor | sudo tee /usr/share/keyrings/tor-archive-keyring.gpg >/dev/null
sudo apt update -y
sudo apt install tor deb.torproject.org-keyring -y
sudo sed '/HiddenServiceDir/s/^#//g' -i /etc/tor/torrc
sudo sed '/HiddenServicePort/s/^#//g' -i /etc/tor/torrc
sudo systemctl restart tor

## LCD SCREEN
# prepare auto-start of qrinfo.sh script on pi user login
bash -c 'echo "# automatic start the QR info loop" >> /home/pi/.bashrc'
bash -c 'echo "# load QR code into frame buffer" >> /home/pi/.bashrc'
bash -c 'echo "sudo fbi -a -T 1 -d /dev/fb0 --noverbose /home/pi/qr.png 2> /dev/null" >> /home/pi/.bashrc'
echo "autostart LCD added"

## QR CODE
# Create QR code from onion url and save as png
sudo cat /var/lib/tor/hidden_service/hostname | sudo qrencode --foreground="ffffff" --background="000000" -o /home/pi/qr.png

# adding main user admin
echo -e "\n*** ADDING MAIN USER admin ***"
sudo adduser --disabled-password --gecos "" admin
echo "admin:admin" | sudo chpasswd
sudo adduser admin sudo
sudo chsh admin -s /bin/bash
# configure sudo for usage without password entry
echo '%sudo ALL=(ALL) NOPASSWD:ALL' | sudo EDITOR='tee -a' visudo
# check if group "admin" was created
if [ $(sudo cat /etc/group | grep -c "^admin") -lt 1 ]; then
  echo -e "\nMissing group admin - creating it ..."
  sudo /usr/sbin/groupadd --force --gid 1002 admin
  sudo usermod -a -G admin admin
else
  echo -e "\nOK group admin exists"
fi

echo "# INSTALL 64bit LCD DRIVER"
# Downloading LCD Driver from Github
cd /home/admin/
sudo -u admin git clone https://github.com/tux1c/wavesharelcd-64bit-rpi.git
sudo -u admin chmod -R 755 wavesharelcd-64bit-rpi
sudo -u admin chown -R admin:admin wavesharelcd-64bit-rpi
cd /home/admin/wavesharelcd-64bit-rpi

# add waveshare mod
sudo cp ./waveshare35a.dtbo /boot/overlays/

# modify /boot/config.txt
sudo sed -i "s/^hdmi_force_hotplug=.*//g" /boot/config.txt
sudo sed -i '/^hdmi_group=/d' /boot/config.txt 2>/dev/null
sudo sed -i "/^hdmi_mode=/d" /boot/config.txt 2>/dev/null

sudo sed -i "s/^dtparam=i2c_arm=.*//g" /boot/config.txt
sudo sed -i "s/^dtoverlay=.*//g" /boot/config.txt

# load module on boot
#cp ./waveshare35a.dtbo /boot/overlays/
#echo "hdmi_force_hotplug=1" >> /boot/config.txt
#echo "dtparam=i2c_arm=on" >> /boot/config.txt
#echo "dtparam=spi=on" >> /boot/config.txt
#echo "enable_uart=1" >> /boot/config.txt
echo "dtoverlay=waveshare35a:rotate=90" | sudo tee -a /boot/config.txt
sudo cp ./cmdline.txt /boot/





# touch screen calibration
#sudo apt-get install xserver-xorg-input-evdev -y
#cp -rf /usr/share/X11/xorg.conf.d/10-evdev.conf /usr/share/X11/xorg.conf.d/45-evdev.conf
# reboot
echo "# OK install of LCD done ... reboot needed"
sudo reboot

echo "# BUILD DONE - see above"
