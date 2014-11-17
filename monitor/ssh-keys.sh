#!/bin/bash



# Monitor SSH Authorized Keys
while true
do
  inotifywait --exclude .swp -e modify /root/.ssh/authorized_keys /var/www/.ssh/authorized_keys
	echo "SSH Authorised Keys Files Modified At `date`" | mail -s "$(hostname -f) SSH Keys Modified" mail@example.com
done
