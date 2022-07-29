# NULL3N & E1NSEN Workshop

## Flash the SD Card

Flash your SD Card with latest Raspberry OS (ARM 64bit Lite) [Tutorial](https://www.raspberrypi.com/documentation/computers/getting-started.html).
- Download Raspberry Pi Imager [Download](https://www.raspberrypi.com/software/)
- Insert Micro SD Card into your local machine card reader
- Start Raspberry Pi Imager App on your local machine:
  - Choose OS > Raspberry Pi OS (other) > Raspberry Pi OS Lite (64bit)
  - Choose Storage > {Your SD Card Name}
  - Click on options and configure:
    - hostname: A name how you will find your device in the network, <hostname>
    - Enable SSH > Use password authentication
    - Set username and password (pi:pi)
    - Configure Wireless Lan (SSID: name of your network, Password: Wifi password, Wireless Country: CH)
    - Save
  - Write (Are you sure? Yes)
- Remove SD Card from local machine when finished

## Start your RBP
- Insert the RBP into the bottom case
- Put the LCD Screen on top
- Insert SD Card into the slot of the Raspberry Pi
- Ensure that your Wifi is enabled (Hotspot on)
- Connect the power cable and wait

## Find the IP of your RBP
- Ensure that you are connected to the same network with your local machine
- Open terminal and run following commands:

```bash
# Replace <hostname> by your setting
ping <hostname>.local

# If upper does not work use ifconfig and nmap as follows (Linux)
ifconfig | grep netmask # to find out your subnetmask
nmap -sn <subnetmask>.0/24
```

## Connect to your RBP
If you have found the IP address of your RBP you can connect via SSH:

```bash
ssh pi@<IP-of-your-RBP>
```

Confirm by typing `yes` and enter the password `pi`.
If you have logged in correctly it should look as follows:

![image](https://user-images.githubusercontent.com/92563141/181783475-493b6fdc-69c8-4238-a80d-98c68d3b0e81.png)


## Build SD Card automatically
If you want setup everything by one command then run the following commands. In case you want to do it manually, follow steps in next section.

```bash
wget https://raw.githubusercontent.com/nullen-einsen/zerone/main/setup.sh && sudo bash /home/pi/setup.sh
```

## Build manually

### Switch to root user and update software

```bash
sudo -su root
sudo apt update -y
sudo apt upgrade -f -y
~~~


