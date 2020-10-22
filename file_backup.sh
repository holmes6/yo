#!/bin/bash
#Run daily at 1am:
# 0 1 * * * ~/file_backup.sh > /var/log/filebackup.log 2>&1

#Location to backup
folder_to_backup="/var/www"
backup_location="/backups/filebackups"
days_retain="7"
backup_disk="/dev/xvdb"
filename="filebackup_`date +%m-%d-%Y-%H.%M`"

#if backup folder doesnt exit create it
        if [ -d "$backup_location" ]  ; then
        echo "Folder $backup_location exists.  Continuing."
        #is backup disk ok for backups?
        backup_status=`/usr/lib/nagios/plugins/check_disk /dev/xvdb|echo $?`
                if [ $backup_status -eq 0 ] ; then
                echo "Disk $backup_disk status OK.  Continuing."
                else
                echo "Disk $backup_disk not OK.  Aborting."
                exit 2
                fi
        else
        echo "Backup location $backup_location not created.  Run mkdir -p $backup_location to create it"
        exit 2
        fi

#Run the backup
tar cvf - $folder_to_backup |gzip -c > $backup_location/$filename.tgz

#remove backups older than $days_retain
find $backup_location -name "filebackup*tgz" -mtime $days_retain -exec rm {} \;
