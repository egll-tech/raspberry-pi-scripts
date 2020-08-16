#!/bin/bash

# Script to install pihole pre-configured with blocklist project whitelisting social media and p2p.
#
# by Eduardo Guzman Lau Len (egll.tech). Based on pihole script

# Check sudo rights
if [[ "$EUID" != 0 ]]; then
    sudo -k # make sure to ask for password on next sudo
    if sudo false; then
        echo "Wrong password"
        exit 1
    fi
fi

# Disabling current DNS server
echo "Disabling current DNS server"
sudo systemctl stop systemd-resolved
sudo systemctl disable systemd-resolved &> /dev/null
echo "Updating default DNS to 1.1.1.3"
sudo sed -i -e 's/127.0.0.53/1.1.1.3/g' /etc/resolv.conf

echo "Installing pihole"
curl -sL https://raw.githubusercontent.com/pi-hole/docker-pi-hole/master/docker_run.sh | sudo -E bash -