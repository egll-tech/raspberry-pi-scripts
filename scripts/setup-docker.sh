#!/bin/bash

# Script to install docker.
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

# Installing required packages
{
	sudo apt update -y
	sudo apt install docker.io -y
} &> /dev/null &
PID=$!
i=1
sp="/-\|"
echo -n 'Installing docker... '
while [ -d /proc/$PID ]
do
  printf "\b${sp:i++%${#sp}:1}"
done
printf "\b \n"

echo "Adding user to docker group"
sudo usermod -aG docker $USER
newgrp docker

sudo systemctl enable docker &> /dev/null
echo "You can login using $(tput bold)docker login $(tput sgr0)"
exit 0

