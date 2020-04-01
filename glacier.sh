#!/bin/bash
#Necessary prerequisites
#apt-get install libwww-perl libjson-xs-perl
#git clone https://github.com/vsespb/mt-aws-glacier.git /etc/aws-glacier
#cron 0 1 * * THU ~/glacier.sh

#USER VARIABLES--CHANGE THESE
glacier_key=""
glacier_secret=""
glacier_region="us-east-1"
glacier_vault="" #Mysqlbackups
logfile=/var/log/aws-glacier/sync.log
backupdir= #/backups/mongo/
template_file=/etc/aws-glacier/config.d/my-backup-template.cfg
#end user variables

stamp=`date +%s`
mkdir /etc/aws-glacier/config.d /etc/aws-glacier/journal.d /var/log/aws-glacier > /dev/null 2>&1

        if [ ! -f "$template_file" ]; then
        echo "key=$glacier_key
secret=$glacier_secret
region=$glacier_region
protocol=https
dir=%DIRECTORY%
vault=$glacier_vault
journal=/etc/aws-glacier/journal.d/$glacier_vault.journal" > $template_file
        fi

mkdir /tmp/upload-$stamp/
        for i in `ls -x1 $backupdir/Wed/*-00*`; do
        ln -s $i /tmp/upload-$stamp/$stamp-`basename $i`
        done
#echo "links created at: /tmp/upload-$stamp/$stamp`basename $i`"
#ls /tmp/upload-$stamp/


sed s=%DIRECTORY%=/tmp/upload-$stamp/=g $template_file > /etc/aws-glacier/config.d/my-backup.cfg
echo "`date` - glacier.sh executing glacier backup" >> $logfile
bash -c '/etc/aws-glacier/mtglacier sync --config /etc/aws-glacier/config.d/my-backup.cfg --new' >> $logfile
        if [ $? -eq 0 ] ; then
        echo "`date` - Backup Command Ran Successfully" >> $logfile
        else
        echo "`date` - PROBLEMS DETECTED - Backup command exited without success" >> $logfile
        fi
rm -Rf /tmp/upload-$stamp/
echo "`date` - glacier.sh completed glacier backup" >> $logfile
