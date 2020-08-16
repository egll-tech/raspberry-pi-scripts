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

sudo docker run -d \
    --name pihole \
    -p 53:53/tcp -p 53:53/udp \
    -p 80:80 \
    -p 443:443 \
    -p 8080:8080 \
    -e TZ="$(timedatectl show -p Timezone | cut -d"=" -f2)" \
    -v "$(pwd)/etc-pihole/:/etc/pihole/" \
    -v "$(pwd)/etc-dnsmasq.d/:/etc/dnsmasq.d/" \
    --dns=127.0.0.1 --dns=1.1.1.1 \
    --restart=unless-stopped \
    egll/pihole

printf 'Starting up pihole container '
for i in $(seq 1 20); do
    if [ "$(sudo docker inspect -f "{{.State.Health.Status}}" pihole)" == "healthy" ] ; then
        printf ' OK'
        echo -e "\n$(sudo docker logs pihole 2> /dev/null | grep 'password:') for your pi-hole: https://${IP}/admin/"
        exit 0
    else
        sleep 3
        printf '.'
    fi

    if [ $i -eq 20 ] ; then
        echo -e "\nTimed out waiting for Pi-hole start, consult check your container logs for more info (\`docker logs pihole\`)"
        exit 1
    fi
done;