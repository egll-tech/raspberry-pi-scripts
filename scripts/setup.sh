#!/bin/bash

# Script to finish setting up Ubuntu Server.
#
# by Eduardo Guzman Lau Len (egll.tech)


# Checking for sudo, required to install packages
if [[ "$EUID" != 0 ]]; then
    sudo -k # make sure to ask for password on next sudo
    if sudo false; then
        echo "Wrong password"
        exit 1
    fi
fi

# Updating server name
read -p "How would you like to name your server: " name
echo "Updating hostname and hosts file"
sudo sed -i "s/.\+/$name/g" /etc/hostname
sudo sed -i "1s;^;127.0.0.1 $name\n;" /etc/hosts


# Installing required packages
{
	sudo apt update --fix-missing -y
	sudo apt upgrade -y
	sudo apt autoremove --purge -y
	sudo apt install wireless-tools -y
} &> /dev/null &
PID=$!
i=1
sp="/-\|"
echo -n 'Updating, upgrading and installing required packages... '
while [ -d /proc/$PID ]
do
  printf "\b${sp:i++%${#sp}:1}"
done
printf "\b \n"

# Disable power save from wlan
echo "Disabling power save on wlan."
cat > /lib/systemd/system/disable-power-save.service <<EOL
[Unit]
Description=Disabling power save
Wants=network-online.target
After=network-online.target

[Service]
Type=oneshot
RemainAfterExit=yes
ExecStart=iwconfig wlan0 power off
ExecStop=iwconfig wlan0 power on

[Install]
WantedBy=multi-user.target
EOL

sudo systemctl daemon-reload
sudo systemctl enable --now disable-power-save.service &> /dev/null

# Add ssh to the firewall
echo "Allowing ssh in the firewall. If you are using ssh, you will need to re-login"
{
  sudo ufw allow ssh
  sudo ufw enable
} &> /dev/null

echo "Your new server is ready to ROLL!"
exit 0