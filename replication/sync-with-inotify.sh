#!/bin/bash



# Add crontab to auto start scripts
# @reboot /bin/bash /root/bin/sync-with-inotify.sh &>> /var/log/sync-with-inotify.log &

# Configure Variables
DOMAIN=
SERVER1=
SERVER2=
SERVER2IP=


while true
do

	# Monitor files changes for create, delete, move, file permissions
	inotifywait --exclude .swp -r -e create -e modify -e delete -e move -e attrib --format %e:%f /var/www/

	# Detect webServer
	curl -sI $DOMAIN/wp-admin/ | grep rt-server | grep $SERVER1

	if [ $? -eq 0 ]
	then
		# Send details to log files
		echo "[$(date)] Sending Changes From $SERVER1 To $SERVER2:"

		# Start synchronization
		# rsync -avz --delete --temp-dir=/tmp /var/www root@$SERVER2IP:/var/
		rsync -avz --temp-dir=/tmp /var/www root@$SERVER2IP:/var/

		# If rsync fails
		if [ $? != 0 ]
		then

			echo "[+] Checking Server Health Script Is Already Running Or Not"
			ps ax | grep check-server-health.sh | grep -v grep

			if [ $? != 0 ]
			then
				echo "[+] Starting Check Server Health Script"
				/bin/bash /root/bin/check-server-health.sh &
			fi
		fi

	else
		# Send details to log files
		echo "The $SERVER2 Is Running, Can't Send Changes From $SERVER1 To $SERVER2:"
	fi
done
