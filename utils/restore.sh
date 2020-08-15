#!/bin/bash

# Script to restore compressed images into the selected disk. It uses 'sudo' so make sure to select the right disk (SD card)
# Developed to be used just with linux.
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

# Get filename
name=$1

if [ -z "$name" ]
then
	echo "Please select the file to restore:"

	select name in $(ls *.img.gz)
	do
		if [ -n "$name" ]
		then
			break
		fi
	done
fi

echo

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


# Restoring backup
{
	gunzip --stdout $name | sudo dd bs=4M of=$drive
} &> /dev/null &
PID=$!
i=1
sp="/-\|"
echo -n "Restoring $name to disk $drive... "
while [ -d /proc/$PID ]
do
  printf "\b${sp:i++%${#sp}:1}"
done
printf "\b \n"
exit 0