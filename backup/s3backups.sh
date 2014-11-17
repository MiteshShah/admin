#!/bin/bash


# Error handling
function error()
{
	echo -e "[ `date` ] $(tput setaf 1)$@$(tput sgr0)" | tee -ai $LOGS
	exit $2
}

### Handle Kernal Signals ####
HandleSignals()
{
	echo -e \\t \\t "Caught termination signal" &>> $LOGS

	#Unset Trap So We Don't Get Infinate Loop
	trap - INT TERM QUIT ABRT KILL

	#Flush File System Buffers
	#More Details: info coreutils 'sync invocation'
	sync

	#Exit The Script
	exit 0
}
trap "HandleSignals" INT TERM QUIT ABRT KILL

LOGS=/var/log/s3backups.log
DOMAIN=Domain.com
DBUSER=root
DBPASSWORD=PASSWORD
DBNAME=DBNAME
S3BUCKET=Domain
DIRNAME=Backups

TIME=$(date +'%d_%b_%Y')
DELETETIME=$(date --date "15 days ago" +'%d_%b_%Y')
echo $TIME $DELETETIME

rm -f /var/www/s3backups/$DOMAIN-htdocs-$DELETETIME.tar.gz
rm -f /var/www/s3backups/$DOMAIN-mysql-$DELETETIME.gz

# Backup $DOMAIN WebRoot
echo "[`date`] Backup $DOMAIN WebRoot..." &>> $LOGS
tar -zcvf /var/www/s3backups/$DOMAIN-htdocs-$TIME.tar.gz /var/www/$DOMAIN/htdocs \
|| eror "Failed backup $DOMAIN webroot, exit status = " $?

# Backup $DOMAIN MySQL
echo "[`date`] Backup $DOMAIN MySQL..." &>> $LOGS
mysqldump --single-transaction -u $DBUSER -p$DBPASSWORD $DBNAME | /bin/gzip -9 > /var/www/s3backups/$DOMAIN-mysql-$TIME.gz \
|| OwnError "Failed backup $DOMAIN MySQL, exit status = " $?


# Start S3Sync
ruby /root/s3sync/s3sync.rb -rv --delete --ssl /var/www/s3backups/ $S3BUCKET:$DIRNAME \
|| error "Unable process s3sync, exit status = " $? 
