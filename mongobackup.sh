#!/bin/bash

# mongo backup script
#Cron
#30 */6 * * * ~/mongobackup.sh
#Install:
#wget -O ~/mongobackup.sh 
export PATH=/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin

MAILTO="jwaltz666@gmail.com;";

hour=`date +%H`
day=`date +%a`

if [ ! -d /backups/mongo/Sun/ ]
 then mkdir -p /backups/mongo/{,Sun,Mon,Tue,Wed,Thu,Fri,Sat}
fi

mongodump --out /backups/mongo/$day/$hour/
tar -zcvf /backups/mongo/$day/mongodump-$hour.tar.gz /backups/mongo/$day/$hour/
rm -Rf /backups/mongo/$day/$hour/
