#!/bin/bash


# Configure variables
SERVER2IP=

while true
do
	# Check server2 become a live
	ping -c1 $SERVER2IP &> /dev/null
	if [ $? == 0 ]
	then
		echo "[+] Server becomes alive......"
		rsync -avz --temp-dir=/tmp /var/www root@$SERVER2IP:/var/
		exit 0;
	fi
done
