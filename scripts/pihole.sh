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
sudo mv /etc/resolv.conf /etc/resolv.conf.bak
sudo cat > /etc/resolv.conf <<EOL
nameserver 1.1.1.3
nameserver 1.0.0.3
EOL

echo "Installing pihole"
curl -sL https://raw.githubusercontent.com/pi-hole/docker-pi-hole/master/docker_run.sh | sudo -E bash -