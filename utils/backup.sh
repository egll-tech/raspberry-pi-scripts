#!/bin/bash

# Script to create a backup from the selected disk (make sure to select the right SD card).
# Developed to be used just with linux.
#
# by Eduardo Guzman Lau Len (egll.tech)

# Check sudo rights. Required to make sure it has the right permits to clone the SD card and compress it.
if [[ "$EUID" = 0 ]]; then
    echo "Already root"
else
    sudo -k # make sure to ask for password on next sudo
    if sudo false; then
        echo "Wrong password"
        exit 1
    fi
fi

# Get filename
name=$1

while [ -z "$name" ]
do
	read -p "Please name the backup: " name
done

# Get drive location
drive=$2

if [ -z "$drive" ]
then
	echo "Please select the drive:"
	readarray -t drives < <(lsblk -I 8,179 -d -o NAME -n)

	select drive in ${drives[*]}
	do
		if [ -n "$drive" ]
		then
			drive="/dev/${drive}"
			break
		fi
	done
fi

# Generating backup
echo "Generating $name from disk $drive..."
{
	sudo dd bs=4M if=$drive | gzip > $name.img.gz 
} &> /dev/null &
PID=$!
i=1
sp="/-\|"
echo -n ' '
while [ -d /proc/$PID ]
do
  printf "\b${sp:i++%${#sp}:1}"
done
printf "\b"
exit 0