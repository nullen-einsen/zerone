# NULL3N & E1NSEN Workshop

## Flash the SD Card

Flash your SD Card with latest Raspberry OS (ARM 64bit Lite) [Tutorial](https://www.raspberrypi.com/documentation/computers/getting-started.html).
- Download Raspberry Pi Imager [Download](https://www.raspberrypi.com/software/)
- Insert Micro SD Card into your local machine card reader
- Start Imager:
-- Choose OS > Raspberry Pi OS (other) > Raspberry Pi OS Lite (64bit)
-- Choose Storage > {Your SD Card Name}
-- Click on options and configure:
--- hostname: A name how you will find your device in the network, <hostname>
--- Enable SSH > Use password authentication
--- Set username and password (pi:pi)
--- Configure Wireless Lan (SSID: name of your network, Password: Wifi password, Wireless Country: CH)
--- Save
-- Write (Are you sure? Yes)
- Remove SD Card when finished

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

# If this does not work, scan the network and find the IP of the device with your hostname

```


## Build SD Card

```bash
wget https://raw.githubusercontent.com/nullen-einsen/zerone/main/build_sdcard.sh && sudo bash build_sdcard.sh
```
