#!/bin/bash
BACKUPSERVER=
echo "Live server MySQL master status:"
mysql -e "show master status \G;"
echo
echo "Backup server MySQL slave status:"
ssh root@$BACKUPSERVER 'mysql -e "show slave status \G;"'

echo
echo
echo "Backup server MySQL master status:"
ssh root@$BACKUPSERVER 'mysql -e "show master status \G;"'
echo
echo "Live server MySQL slave status:"
mysql -e "show slave status \G;"
