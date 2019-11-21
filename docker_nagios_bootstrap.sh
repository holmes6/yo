#!/bin/bash
apt-get -y install nagios-nrpe-server nagios-plugins
sed 's/allowed_hosts=127.0.0.1/allowed_hosts=127.0.0.1,45.79.181.247/g' /etc/nagios/nrpe.cfg -i
echo "command[check_disk]=/usr/lib/nagios/plugins/check_disk -w 20% -c 10% -p /dev/xvda1" >> /etc/nagios/nrpe.cfg
service nagios-nrpe-server restart
netstat -nlp|grep 5666
