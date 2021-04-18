#!/bin/sh
## BASED ON https://github.com/digiapulssi/docker-zabbix-agent/blob/master/files/run.sh
set -e

if [ -z "$ZABBIX_SERVER" ]; then
    echo "ZABBIX_SERVER environment variable is empty"
    exit 1
fi

if [ -z "$HOST" ]; then
    MACHINEID=$(cat /etc/machine-id)
    HOST="$METADATA-$MACHINEID"
    echo "HOST environment variable is empty, using generated host name $HOST"
fi

sed -i "s/^Server\=127.0.0.1/Server\=$ZABBIX_SERVER/" /etc/zabbix/zabbix_agentd.conf
sed -i "s/^ServerActive\=127.0.0.1/ServerActive\=$ZABBIX_SERVER/" /etc/zabbix/zabbix_agentd.conf
sed -i "s/^PidFile\=\/var\/run\/zabbix\/zabbix_agentd.pid/PidFile\=\/tmp\/zabbix_agentd.pid/" /etc/zabbix/zabbix_agentd.conf
# Log to stdout so that docker can capture it
sed -i "s/^LogFile\=.*/LogFile=\/proc\/self\/fd\/1/" /etc/zabbix/zabbix_agentd.conf
echo "Hostname=$HOST" >> /etc/zabbix/zabbix_agentd.conf
echo "HostMetadata=$METADATA" >> /etc/zabbix/zabbix_agentd.conf
echo "AllowRoot=1" >> /etc/zabbix/zabbix_agentd.conf

cat /etc/zabbix/zabbix_agentd.conf

apcupsd -b &
zabbix_agentd -f
