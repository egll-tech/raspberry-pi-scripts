#!/bin/bash

# Script to setup a bridge network and keeping your router DHCP as server. Used to extend your current
# network or provide wifi to old devices.
#
# by Eduardo Guzman Lau Len (egll.tech)

# Check sudo rights
if [[ "$EUID" != 0 ]]; then
    sudo -k # make sure to ask for password on next sudo
    if sudo false; then
        echo "Wrong password"
        exit 1
    fi
fi

bold=$(tput bold)
normal=$(tput sgr0)

# Message
echo "======================================= I M P O R T A N T ======================================="
echo "Please modify your network settings in ${bold}/etc/netplan/${normal} following this guidelines:"
echo "1) set ${bold}renderer${normal} to ${bold}networkd${normal} or ${bold}NetworkManager${normal}"
echo "2) set your ${bold}ethernet (eth0) dhcp4${normal} to ${bold}false${normal}"
echo "3) set your ${bold}wifi (wlan0) dhcp4${normal} to ${bold}true${normal}"
echo "4) remove ${bold}eth0${normal} and ${bold}wlan0${normal} from any bridge"
echo "4) execute ${bold}sudo netplan --debug try${normal}"
echo "5) execute ${bold}sudo netplan --debug generate${normal}"
echo "7) execute ${bold}sudo netplan --debug apply${normal}"
echo "-------------------------------------------------------------------------------------------------"
echo "In case you set ${bold}NetworkManager${normal} remember to set ${bold}/etc/default/crda${normal}"
echo "================================================================================================="

# Disabling power save
curl -sL https://raw.githubusercontent.com/egll-tech/raspberry-pi-scripts/master/scripts/setup.sh | sudo -E bash -

# Updating and installing packages
{
	sudo apt install wireless-tools wpasupplicant parprouted dhcp-helper avahi-daemon -y -f
} &> /dev/null &
PID=$!
i=1
sp="/-\|"
echo -n "Installing ${bold}parprouted dhcp-helper wireless-tools wpasupplicant avahi-daemon${normal}... "
while [ -d /proc/$PID ]
do
  printf "\b${sp:i++%${#sp}:1}"
done
printf "\b \n"

# Updating configuration files
sudo sed -i -e 's/eth0/wlan0/g' /etc/default/dhcp-helper
sudo sed -i -e 's/#enable-reflector=no/enable-reflector=yes/g' /etc/avahi/avahi-daemon.conf

# Generating service file
cat > /lib/systemd/system/arp-bridge.service <<EOL
[Unit]
Description=ARP Bridge over Wireless Interface
Wants=network-online.target
After=network-online.target

[Service]
Type=oneshot
RemainAfterExit=yes
ExecStart=/lib/systemd/system/set-arp-routing start
ExecStop=/lib/systemd/system/set-arp-routing stop
ExecReload=/lib/systemd/system/set-arp-routing restart

[Install]
WantedBy=multi-user.target
EOL

# Creating script
sudo curl -o /lib/systemd/system/set-arp-routing https://raw.githubusercontent.com/egll-tech/raspberry-pi-scripts/master/scripts/set-arp-routing.sh &> /dev/null
sudo chmod -v u+x /lib/systemd/system/set-arp-routing &> /dev/null

# Reload systemd config
sudo systemctl daemon-reload

# Enable and start the service
sudo systemctl enable --now arp-bridge.service &> /dev/null

# Final message
echo "${bold}Please reboot your pi"
exit 0