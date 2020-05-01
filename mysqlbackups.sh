#!/bin/bash
# mysql backup script
#apt-get install libdbd-mysql-perl libdbi-perl
#wget -O /usr/lib/nagios/plugins/check_mysql_health https://raw.githubusercontent.com/holmes6/yo/master/check_mysql_health
#chmod 755 /usr/lib/nagios/plugins/check_mysql_health
#Crontab
#0 */6 * * * ~/mysqlbackups.sh

export PATH=/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin

MAILTO="jwaltz666@gmail.com;";
mysqldir="/var/lib/mysql"
logfile="/var/log/mysqlbackup.log"

#Abort if we cannot login as root
mycnf=`cat /root/.my.cnf`
myuser=`echo $mycnf|cut -d "=" -f 2|cut -d " " -f 1|sed s=\'==g`
mypass=`echo $mycnf|cut -d "=" -f 3|cut -d " " -f 1|sed s=\'==g`
mysqllogin=`/usr/lib/nagios/plugins/check_mysql_health --user "$myuser" --password "$mypass" --mode connection-time`
        if [ $? -ne 0 ] ; then
        echo "`date` - PROBLEMS DETECTED MysqlBackup Aborted.. NO VALID LOGIN in ~/.my.cnf" >> $logfile
        exit 2
        fi


hour=`date +%H`
fail=0
backup_mysql () {
        if [ ! -d /mysqlbackups/Sun/ ] ; then
        mkdir /mysqlbackups/{,Sun,Mon,Tue,Wed,Thu,Fri,Sat}
        fi

        for i in $(find ${mysqldir}/* -maxdepth 1 -type d|grep -v information_schema|grep -v performance_schema) ; do
        echo "`date` - Starting Dump on `basename $i`"
        mysqldump --opt -Q -B $(basename $i) > /mysqlbackups/$(date +%a)/$(basename $i)-$hour.sql
                if [ $? -eq 0 ] ; then
                echo "`date` - Success dumping database `basename $i`"
                else
                echo "`date` - Failed to dump database `basename $i`"
                fail=1
                fi
        echo "`date` - Starting Compression of archive for `basename $i`"
        gzip -f /mysqlbackups/$(date +%a)/$(basename $i)-$hour.sql
                if [ $? -eq 0 ] ; then
                echo "`date` - Success Compressing `basename $i` database"
                else
                echo "`date` - Failed Compressing `basename $i` database"
                fail=1
                fi
        done
}

echo "******************************************" >> $logfile
echo "`date` - MysqlBackup Started" >> $logfile
backup_mysql >> $logfile 2>&1
        if [ $fail -eq 1 ] ; then
        echo "`date` - PROBLEMS DETECTED.. See log above for details"
        else
        echo "`date` - All commands completed successfully" >> $logfile
        fi
echo "`date` - MysqlBackup Completed" >> $logfile
echo "******************************************

" >> $logfile
