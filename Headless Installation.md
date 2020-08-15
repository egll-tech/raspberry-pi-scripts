# Headless installation

Usually when you create a new pi image, there are certain steps before you can use it properly, so most people would need a keyboard and HDMI cable to be able to access and change the initial settings. There is a way to avoid that and be ready to use wifi and ssh without accessing it directly.
It's separated in multiple sections, use and modify as required. Keep in mind, in most scenarios the auto reboot is important for the first boot.

### Preparation

1. Use [Raspberry Pi imager](https://www.raspberrypi.org/downloads/) to install the OS of choice. I will be picking \_Ubuntu Server 20.04.1
1. Once the process has finished. Remove and re-insert the SD card.
1. Access the partition **system-boot**

### WiFi settings

1. Open the file **network-config**
1. Remove the comments (#) from the respective lines and modify the wifi settings as needed. You can [follow this link to access some examples](https://netplan.io/examples/).
   > IMPORTANT: Use space and not 'tabs'. Respect the indentation

```
# This file contains a netplan-compatible configuration which cloud-init
# will apply on first-boot. Please refer to the cloud-init documentation and
# the netplan reference for full details:
#
# https://cloudinit.readthedocs.io/
# https://netplan.io/reference
#
# Some additional examples are commented out below

version: 2
ethernets:
  eth0:
    dhcp4: true
    optional: true
wifis:
  wlan0:
    dhcp4: true
    optional: true
    access-points:
      myhomewifi:
        password: "S3kr1t"
```

### Auto reboot when finished setup

This step is IMPORTANT, because the first time you boot the OS, it will take some time to apply all the changes and after that it's neccesary to reboot the system, else some features might not be working as expected (including the wifi).

1. Open the file **user-data**
1. Append this to the end of the file

```
power_state:
  mode: reboot
```

### Success!

If you reach here, you have finished the headless setup. Now remove the SD card put it in your Pi and wait some minutes before accessing with SSH.
