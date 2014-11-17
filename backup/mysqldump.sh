#!/bin/bash


# -------------------------------------------------------------------------
# Modified By: Mitesh Shah
# Copyright (c) 2007 Vivek Gite <vivek@nixcraft.com>
# This script is licensed under GNU GPL version 2.0 or above
# -------------------------------------------------------------------------
# This script is part of nixCraft shell script collection (NSSC)
# Visit http://bash.cyberciti.biz/ for more information.
# -------------------------------------------------------------------------

# Error handling
function error()
{
	echo -e "[ `date` ] $(tput setaf 1)$@$(tput sgr0)"
	exit $2
}


### Set Bins Path ###
RM=/bin/rm
GZIP=/bin/gzip
GREP=/bin/grep
MKDIR=/bin/mkdir
MYSQL=/usr/bin/mysql
MYSQLDUMP=/usr/bin/mysqldump
MYSQLADMIN=/usr/bin/mysqladmin

### Enable Log = 1 ###
LOGS=1

### Default Time Format ###
TIME_FORMAT='%d%b%Y%H%M%S'
 
### Setup Dump And Log Directory ###
MYSQLDUMPPATH=/var/www/mysqldump
MYSQLDUMPLOG=/var/log/mysqldump.log
EXTRA_PARAMS=$1

#####################################
### ----[ No Editing below ]------###
#####################################

[ -f ~/.my.cnf ] || error "Error: ~/.my.cnf not found"

### Make Sure Bins Exists ###
verify_bins(){
	[ ! -x $GZIP ] && error "File $GZIP does not exists. Make sure correct path is set in $0."
	[ ! -x $MYSQL ] && error "File $MYSQL does not exists. Make sure correct path is set in $0."
	[ ! -x $MYSQLDUMP ] && error "File $MYSQLDUMP does not exists. Make sure correct path is set in $0."
	[ ! -x $RM ] && error "File $RM does not exists. Make sure correct path is set in $0."
	[ ! -x $MKDIR ] && error "File $MKDIR does not exists. Make sure correct path is set in $0."
	[ ! -x $MYSQLADMIN ] && error "File $MYSQLADMIN does not exists. Make sure correct path is set in $0."
	[ ! -x $GREP ] && error "File $GREP does not exists. Make sure correct path is set in $0."
}


### Make Sure We Can Connect To The Server ###
verify_mysql_connection(){
	$MYSQLADMIN  ping | $GREP 'alive' > /dev/null
	[ $? -eq 0 ] || error "Error: Cannot connect to MySQL Server. Make sure username and password are set correctly in $0"
}


### Make A Backup ###
backup_mysql_rsnapshot(){
	local DBS="$($MYSQL -Bse 'show databases')"
	local db="";

	[ ! -d $MYSQLDUMPLOG ] && $MKDIR -p $MYSQLDUMPLOG
	[ ! -d $MYSQLDUMPPATH ] && $MKDIR -p $MYSQLDUMPPATH
	$RM -f $MYSQLDUMPPATH/* > /dev/null 2>&1

	[ $LOGS -eq 1 ] && echo "" &>> $MYSQLDUMPLOG/rsnap-mysql.log
	[ $LOGS -eq 1 ] && echo "*** Dumping MySQL Database At $(date) ***" &>> $MYSQLDUMPLOG/rsnap-mysql.log
	[ $LOGS -eq 1 ] && echo "Database >> " &>> $MYSQLDUMPLOG/rsnap-mysql.log

	for db in $DBS
	do
		local TIME=$(date +"$TIME_FORMAT")
		local FILE="$MYSQLDUMPPATH/$db.$TIME.gz"
		[ $LOGS -eq 1 ] && echo -e \\t "$db" &>> $MYSQLDUMPLOG/rsnap-mysql.log
		
		if [  $db = "mysql" ]
		then
			$MYSQLDUMP --events --single-transaction $EXTRA_PARAMS $db | $GZIP -9 > $FILE || echo -e \\t \\t "MySQLDump Failed $db"
		else
			$MYSQLDUMP --single-transaction $db $EXTRA_PARAMS | $GZIP -9 > $FILE || echo -e \\t \\t "MySQLDump Failed $db"
		fi
	done
	[ $LOGS -eq 1 ] && echo "*** Backup Finished At $(date) [ files wrote to $MYSQLDUMPPATH] ***" &>> $MYSQLDUMPLOG/rsnap-mysql.log
}


### Main ####
verify_bins
verify_mysql_connection
backup_mysql_rsnapshot
